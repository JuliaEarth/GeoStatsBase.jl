# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    uniquecoords(sdata, agg=Dict())

Retain locations in spatial objects with unique coordinates.

Duplicates of a variable `var` are aggregated with
aggregation function `agg[var]`. Default aggregation
function is `mean` for continuous variables and `first`
otherwise.
"""
function uniquecoords(sdata; agg=Dict())
  # retrieve filtering info
  vars = variables(sdata)
  for var in name.(vars)
    if var ∉ keys(agg)
      ST = scitype(sdata[var][1])
      agg[var] = ST <: Continuous ? _mean : _first
    end
  end

  # group locations with the same coordinates
  gind = _uniqueinds(coordinates(sdata), 2)
  groups = Dict(ind => Vector{Int}() for ind in unique(gind))
  for (i, ind) in enumerate(gind)
    push!(groups[ind], i)
  end

  # construct new point set data
  locs = Vector{Int}()
  vals = Dict(name(var) => Vector{mactype(var)}() for var in vars)
  for g in values(groups)
    i = g[1] # select any location
    if length(g) > 1
      # aggregate variables
      for var in name.(vars)
        push!(vals[var], agg[var](sdata[var][g]))
      end
    else
      # copy location
      for var in name.(vars)
        push!(vals[var], sdata[var][i])
      end
    end
    push!(locs, i)
  end

  # construct data with correct variable order
  ctor = Tables.materializer(values(sdata))
  data = ctor([var => vals[var] for var in name.(vars)])
  coords = coordinates(sdata, locs)

  georef(data, coords)
end

function _mean(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : mean(vs)
end

function _first(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : first(vs)
end

# ---------------------------------------------------------------
# The code below was copied/modified provisorily from Base.unique
# See https://github.com/JuliaLang/julia/issues/1845
# ---------------------------------------------------------------
using Base.Cartesian: @nref, @nloops

import Base: hash
struct Prehashed hash::UInt; end
hash(x::Prehashed) = x.hash

@generated function _uniqueinds(A::AbstractArray{T,N}, dim::Int) where {T,N}
  quote
    if !(1 <= dim <= $N)
      ArgumentError("Input argument dim must be 1 <= dim <= $N, but is currently $dim")
    end
    hashes = zeros(UInt, size(A, dim))

    # Compute hash for each row
    k = 0
    @nloops $N i A d->(if d == dim; k = i_d; end) begin
      @inbounds hashes[k] = hash(hashes[k], hash((@nref $N A i)))
    end

    # Collect index of first row for each hash
    uniquerow = Array{Int}(undef,size(A, dim))
    firstrow = Dict{Prehashed,Int}()
    for k = 1:size(A, dim)
      uniquerow[k] = get!(firstrow, Prehashed(hashes[k]), k)
    end
    uniquerows = collect(values(firstrow))

    # Check for collisions
    collided = falses(size(A, dim))
    @inbounds begin
      @nloops $N i A d->(if d == dim
                           k = i_d
                           j_d = uniquerow[k]
                         else
                           j_d = i_d
                         end) begin
        if (@nref $N A j) != (@nref $N A i)
          collided[k] = true
        end
      end
    end

    if any(collided)
      nowcollided = BitArray(undef, size(A, dim))
      while any(collided)
        # Collect index of first row for each collided hash
        empty!(firstrow)
        for j = 1:size(A, dim)
          collided[j] || continue
          uniquerow[j] = get!(firstrow, Prehashed(hashes[j]), j)
        end
        for v in values(firstrow)
          push!(uniquerows, v)
        end

        # Check for collisions
        fill!(nowcollided, false)
        @nloops $N i A d->begin
          if d == dim
            k = i_d
            j_d = uniquerow[k]
            (!collided[k] || j_d == k) && continue
          else
            j_d = i_d
          end
        end begin
          if (@nref $N A j) != (@nref $N A i)
            nowcollided[k] = true
          end
        end
        (collided, nowcollided) = (nowcollided, collided)
      end
    end

    ie = unique(uniquerow)
    ic_dict = Dict{Int,Int}()
    for k = 1:length(ie)
      ic_dict[ie[k]] = k
    end

    ic = similar(uniquerow)
    for k = 1:length(ic)
      ic[k] = ie[ic_dict[uniquerow[k]]]
    end

    ic
  end
end

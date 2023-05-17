# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniqueCoords(var₁ => agg₁, var₂ => agg₂, ..., varₙ => aggₙ)

Retain locations in data with unique coordinates.

Duplicates of a variable `varᵢ` are aggregated with
aggregation function `aggᵢ`. If an aggregation function 
is not defined for variable `varᵢ`, the default aggregation 
function will be used. Default aggregation function is `mean` for
continuous variables and `first` otherwise.

# Examples

```julia
UniqueCoords(1 => last, 2 => maximum)
UniqueCoords(:a => first, :b => minimum)
UniqueCoords("a" => last, "b" => maximum)
```
"""
struct UniqueCoords{S<:ColSpec} <: StatelessTableTransform
  colspec::S
  aggfuns::Vector{Function}
end

UniqueCoords() = UniqueCoords(NoneSpec(), Function[])
UniqueCoords(pairs::Pair{C,<:Function}...) where {C<:Col} = 
  UniqueCoords(colspec(first.(pairs)), collect(Function, last.(pairs)))

isrevertible(::Type{UniqueCoords}) = false

function apply(transform::UniqueCoords, data::Data)
  dom = domain(data)
  tab = values(data)
  sch = Tables.schema(tab)
  vars, types = sch.names, sch.types
  mactype = Dict(zip(vars, types))
  svars = choose(transform.colspec, vars)
  agg = Dict(zip(svars, transform.aggfuns))

  # filtering info
  for var in vars
    if !haskey(agg, var)
      v = getproperty(data, var)
      agg[var] = elscitype(v) <: Continuous ? _mean : _first
    end
  end

  # group locations with the same coordinates
  pts = [centroid(dom, i) for i in 1:nelements(dom)]
  X = reduce(hcat, coordinates.(pts))
  ginds = _uniqueinds(X, 2)
  groups = Dict(ind => Int[] for ind in unique(ginds))
  for (i, ind) in enumerate(ginds)
    push!(groups[ind], i)
  end

  # perform aggregation with repeated indices
  locs = Int[]
  vals = Dict(var => mactype[var][] for var in vars)
  for g in values(groups)
    i = g[1] # select any location
    if length(g) > 1
      # aggregate variables
      for var in vars
        v = getproperty(data, var)
        push!(vals[var], agg[var](v[g]))
      end
    else
      # copy location
      for var in vars
        v = getproperty(data, var)
        push!(vals[var], v[i])
      end
    end
    push!(locs, i)
  end

  # construct new table
  𝒯 = (; (var => vals[var] for var in vars)...)
  newtab = 𝒯 |> Tables.materializer(tab)

  # construct new domain
  newdom = view(dom, locs)

  # new data tables
  newvals = Dict(paramdim(newdom) => newtab)

  # new spatial data
  newdata = constructor(data)(newdom, newvals)

  newdata, nothing
end

# ------------
# AGGREGATION
# ------------

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

struct Prehashed
  hash::UInt
end

Base.hash(x::Prehashed) = x.hash

@generated function _uniqueinds(A::AbstractArray{T,N}, dim::Int) where {T,N}
  quote
    if !(1 <= dim <= $N)
      ArgumentError("Input argument dim must be 1 <= dim <= $N, but is currently $dim")
    end
    hashes = zeros(UInt, size(A, dim))

    # Compute hash for each row
    k = 0
    @nloops $N i A d -> (
      if d == dim
        k = i_d
      end
    ) begin
      @inbounds hashes[k] = hash(hashes[k], hash((@nref $N A i)))
    end

    # Collect index of first row for each hash
    uniquerow = Array{Int}(undef, size(A, dim))
    firstrow = Dict{Prehashed,Int}()
    for k in 1:size(A, dim)
      uniquerow[k] = get!(firstrow, Prehashed(hashes[k]), k)
    end
    uniquerows = collect(values(firstrow))

    # Check for collisions
    collided = falses(size(A, dim))
    @inbounds begin
      @nloops $N i A d -> (
        if d == dim
          k = i_d
          j_d = uniquerow[k]
        else
          j_d = i_d
        end
      ) begin
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
        for j in 1:size(A, dim)
          collided[j] || continue
          uniquerow[j] = get!(firstrow, Prehashed(hashes[j]), j)
        end
        for v in values(firstrow)
          push!(uniquerows, v)
        end

        # Check for collisions
        fill!(nowcollided, false)
        @nloops $N i A d -> begin
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
    for k in 1:length(ie)
      ic_dict[ie[k]] = k
    end

    ic = similar(uniquerow)
    for k in 1:length(ic)
      ic[k] = ie[ic_dict[uniquerow[k]]]
    end

    ic
  end
end

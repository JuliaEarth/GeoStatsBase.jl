# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NearestMapper

A mapping strategy in which data points are assigned to their nearest
point in the domain.
"""
struct NearestMapper <: AbstractMapper end

function map(sdata, sdomain, targetvars, mapper::NearestMapper)
  N = ndims(sdata)
  T = coordtype(sdata)

  @assert targetvars ⊆ keys(variables(sdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # pre-allocate memory for coordinates
  coords = MVector{N,T}(undef)

  # nearest neighbor search method
  neighbor = Vector{Int}(undef, 1)
  searcher = NearestNeighborSearcher(sdomain, 1)

  for ind in 1:npoints(sdata)
    # update datum coordinates
    coordinates!(coords, sdata, ind)

    # find nearest location in the domain
    search!(neighbor, coords, searcher)

    # save pair if there is data for variable
    for var in targetvars
      if isvalid(sdata, ind, var)
        push!(mappings[var], neighbor[1] => ind)
      end
    end
  end

  mappings
end

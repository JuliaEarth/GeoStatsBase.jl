# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    NearestMapper

A mapping strategy in which data points are assigned to their nearest
point in the domain.
"""
struct NearestMapper <: AbstractMapper end

function Base.map(spatialdata::AbstractData{T,N},
                  domain::AbstractDomain{T,N},
                  targetvars::NTuple{K,Symbol},
                  mapper::NearestMapper) where {N,T,K}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # pre-allocate memory for coordinates
  coords = MVector{N,T}(undef)

  # nearest neighbor search method
  neighbor = Vector{Int}(undef, 1)
  searcher = NearestNeighborSearcher(domain, 1)

  for ind in 1:npoints(spatialdata)
    # update datum coordinates
    coordinates!(coords, spatialdata, ind)

    # find nearest location in the domain
    search!(neighbor, coords, searcher)

    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, ind, var)
        push!(mappings[var], neighbor[1] => ind)
      end
    end
  end

  mappings
end

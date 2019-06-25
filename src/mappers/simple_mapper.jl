# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SimpleMapper

A mapping strategy in which data points are assigned to their nearest
point in the domain.
"""
struct SimpleMapper <: AbstractMapper end

function Base.map(spatialdata::AbstractSpatialData{T,N},
                  domain::AbstractDomain{T,N},
                  targetvars::NTuple{K,Symbol},
                  mapper::SimpleMapper) where {N,T,K}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # pre-allocate memory for coordinates
  coords = MVector{N,T}(undef)

  for ind in 1:npoints(spatialdata)
    # update datum coordinates
    coordinates!(coords, spatialdata, ind)

    # find nearest location in the domain
    near = nearestlocation(domain, coords)

    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, ind, var)
        push!(mappings[var], near => ind)
      end
    end
  end

  mappings
end

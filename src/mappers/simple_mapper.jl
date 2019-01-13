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
                  targetvars::Vector{Symbol},
                  mapper::SimpleMapper) where {N,T<:Real}
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

"""
    nearestlocation(domain, coords)

Return the nearest location of `coords` in the `domain`.
"""
function nearestlocation(domain::AbstractDomain{T,N},
                         coords::AbstractVector{T}) where {N,T<:Real}
  lmin, dmin = 0, Inf
  c = MVector{N,T}(undef)
  for l in 1:npoints(domain)
    coordinates!(c, domain, l)
    d = norm(coords - c)
    d < dmin && ((lmin, dmin) = (l, d))
  end

  lmin
end

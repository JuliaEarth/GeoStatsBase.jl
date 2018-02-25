# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SimpleMapper

A mapping strategy in which data points are assigned to their nearest
point in the domain.
"""
struct SimpleMapper <: AbstractMapper end

function Base.map(spatialdata::S, domain::D, targetvars::Vector{Symbol},
                  mapper::SimpleMapper) where {S<:AbstractSpatialData,D<:AbstractDomain}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  for location in 1:npoints(spatialdata)
    # get datum coordinates
    coords = coordinates(spatialdata, location)

    # find nearest location in the domain
    near = nearestlocation(domain, coords)

    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, location, var)
        push!(mappings[var], near => location)
      end
    end
  end

  mappings
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    CopyMapper

A mapping strategy in which data points are copied directly to the
domain at the same location.
"""
struct CopyMapper <: AbstractMapper
  locations::Union{Vector{Int},Nothing}
end

CopyMapper() = CopyMapper(nothing)

function Base.map(spatialdata::S, domain::D, targetvars::Vector{Symbol},
                  mapper::CopyMapper) where {S<:AbstractSpatialData,D<:AbstractDomain}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # locations in domain where to copy the data
  locations = mapper.locations ≠ nothing ? mapper.locations : 1:npoints(spatialdata)

  @assert length(locations) == npoints(spatialdata) "invalid indices in copy mapper"

  for ind in 1:npoints(spatialdata)
    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, ind, var)
        push!(mappings[var], locations[ind] => ind)
      end
    end
  end

  mappings
end

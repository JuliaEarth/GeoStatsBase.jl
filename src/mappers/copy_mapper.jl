# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    CopyMapper

A mapping strategy in which data points are copied directly to the
domain at the same location.
"""
struct CopyMapper <: AbstractMapper end

function Base.map(spatialdata::S, domain::D, targetvars::Vector{Symbol},
                  mapper::CopyMapper) where {S<:AbstractSpatialData,D<:AbstractDomain}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  for location in 1:npoints(spatialdata)
    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, location, var)
        push!(mappings[var], location => location)
      end
    end
  end

  mappings
end

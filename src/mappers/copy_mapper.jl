# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CopyMapper

A mapping strategy in which data points are copied directly to the
domain at specified locations.
"""
struct CopyMapper{V1,V2} <: AbstractMapper
  orig::V1
  dest::V2
end

CopyMapper(dest) = CopyMapper(nothing, dest)
CopyMapper() = CopyMapper(nothing, nothing)

function Base.map(spatialdata::AbstractData{T,N},
                  domain::AbstractDomain{T,N},
                  targetvars::NTuple{K,Symbol},
                  mapper::CopyMapper) where {N,T,K}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # retrieve origin and destination indices
  orig = mapper.orig ≠ nothing ? mapper.orig : 1:npoints(spatialdata)
  dest = mapper.dest ≠ nothing ? mapper.dest : 1:npoints(spatialdata)

  @assert length(orig) == length(dest) "invalid mapping specification"

  for i in eachindex(orig, dest)
    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, orig[i], var)
        push!(mappings[var], dest[i] => orig[i])
      end
    end
  end

  mappings
end

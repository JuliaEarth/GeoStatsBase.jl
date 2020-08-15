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

function map(sdata, sdomain, targetvars, mapper::CopyMapper)
  @assert targetvars ⊆ name.(variables(sdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # retrieve origin and destination indices
  orig = isnothing(mapper.orig) ? (1:npoints(sdata)) : mapper.orig
  dest = isnothing(mapper.dest) ? (1:npoints(sdata)) : mapper.dest

  @assert length(orig) == length(dest) "invalid mapping specification"

  for i in eachindex(orig, dest)
    # save pair if there is data for variable
    for var in targetvars
      if !ismissing(sdata[orig[i],var])
        push!(mappings[var], dest[i] => orig[i])
      end
    end
  end

  mappings
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CopyMapping

A mapping method in which data points are copied directly to the
domain at specified locations.
"""
struct CopyMapping{V1,V2} <: MappingMethod
  orig::V1
  dest::V2
end

CopyMapping(dest) = CopyMapping(nothing, dest)
CopyMapping() = CopyMapping(nothing, nothing)

function map(sdata, sdomain, targetvars, method::CopyMapping)
  @assert targetvars ⊆ name.(variables(sdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # retrieve origin and destination indices
  orig = isnothing(method.orig) ? (1:nelements(sdata)) : method.orig
  dest = isnothing(method.dest) ? (1:nelements(sdata)) : method.dest

  @assert length(orig) == length(dest) "invalid mapping specification"

  for i in eachindex(orig, dest)
    # save pair if there is data for variable
    for var in targetvars
      if !ismissing(sdata[var][orig[i]])
        push!(mappings[var], dest[i] => orig[i])
      end
    end
  end

  mappings
end

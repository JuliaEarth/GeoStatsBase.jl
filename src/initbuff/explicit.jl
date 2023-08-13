# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ExplicitInit(orig, dest)
    ExplicitInit(dest)
    ExplicitInit()

A method to initialize  buffers using explicit lists of indices
`orig` and `dest` in the data and domain, respectively.
"""
struct ExplicitInit{V1,V2} <: InitMethod
  orig::V1
  dest::V2
end

ExplicitInit(dest) = ExplicitInit(nothing, dest)
ExplicitInit() = ExplicitInit(nothing, nothing)

preprocess(sdata, sdomain, vars, ::ExplicitInit) = nothing

function initbuff!(buff, vals, method::ExplicitInit, preproc)
  # retrieve origin and destination indices
  orig = isnothing(method.orig) ? (1:length(vals)) : method.orig
  dest = isnothing(method.dest) ? (1:length(vals)) : method.dest

  @assert length(orig) == length(dest) "invalid explicit initialization"

  @inbounds for ind in eachindex(orig, dest)
    i, j = orig[ind], dest[ind]
    ismissing(vals[i]) || (buff[j] = vals[i])
  end

  buff
end

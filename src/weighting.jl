# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeoWeights(domain, weights)

Assign `weights` to each point in spatial `domain`.

### Notes

Implement AbstractWeights interface from StatsBase.jl.
"""
mutable struct GeoWeights{S,T,V<:AbstractVector{T},D} <: AbstractWeights{S,T,V}
  domain::D
  values::V
  sum::S
end

GeoWeights(domain::D, values::V) where {D,V} = GeoWeights(domain, values, sum(values))

@inline function varcorrection(w::GeoWeights, corrected::Bool=false)
  corrected && throw(ArgumentError("GeoWeights type does not support bias correction."))
  1 / w.sum
end

# -----------
# IO METHODS
# -----------

function Base.show(io::IO, w::GeoWeights)
  npts = nelements(w.domain)
  print(io, "$npts GeoWeights")
end

function Base.show(io::IO, ::MIME"text/plain", w::GeoWeights)
  println(io, w)
  Base.print_array(io, w.values)
end

"""
    WeightingMethod

A method to weight spatial data.
"""
abstract type WeightingMethod end

"""
    weight(object, method)

Weight spatial `object` with `method`.
"""
function weight end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("weighting/uniform.jl")
include("weighting/block.jl")
include("weighting/densratio.jl")

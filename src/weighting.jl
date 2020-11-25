# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialWeights(domain, weights)

Assign `weights` to each point in spatial `domain`.

### Notes

Implement AbstractWeights interface from StatsBase.jl.
"""
mutable struct SpatialWeights{S,T,V<:AbstractVector{T},D} <: AbstractWeights{S,T,V}
  domain::D
  values::V
  sum::S
end

SpatialWeights(domain::D, values::V) where {D,V} =
  SpatialWeights(domain, values, sum(values))

domain(w::SpatialWeights) = w.domain

@inline function varcorrection(w::SpatialWeights, corrected::Bool=false)
    corrected && throw(ArgumentError("SpatialWeights type does not support bias correction."))
    1 / w.sum
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, w::SpatialWeights)
  npts = nelms(w.domain)
  print(io, "$npts SpatialWeights")
end

function Base.show(io::IO, ::MIME"text/plain", w::SpatialWeights)
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
weight(object, method::WeightingMethod) =
  weight(geotrait(object), object, method)

# ----------------
# IMPLEMENTATIONS
# ----------------
include("weighting/block.jl")
include("weighting/densratio.jl")

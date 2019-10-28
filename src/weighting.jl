# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialWeights(domain, weights)

Assign `weights` to each point in spatial `domain`.

### Notes

Implement AbstractWeights interface from StatsBase.jl.
"""
mutable struct SpatialWeights{S<:Real,T<:Real,
                              V<:AbstractVector{T},
                              D<:AbstractDomain} <: AbstractWeights{S,T,V}
  domain::D
  values::V
  sum::S
end

SpatialWeights(domain::D, values::V) where {D<:AbstractDomain,
                                            V<:AbstractVector} =
  SpatialWeights(domain, values, sum(values))

domain(w::SpatialWeights) = w.domain

@inline function varcorrection(w::SpatialWeights, corrected::Bool=false)
    corrected && throw(ArgumentError("SpatialWeights type does not support bias correction."))
    1 / w.sum
end

"""
    AbstractWeighter

A method to weight spatial data.
"""
abstract type AbstractWeighter end

"""
    weight(object, weighter)

Weight spatial `object` with `weighter` method.
"""
weight(object::AbstractSpatialObject, weighter::AbstractWeighter) =
  @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("weighting/block_weighter.jl")
include("weighting/kliep_weighter.jl")

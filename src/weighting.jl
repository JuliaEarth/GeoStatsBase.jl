# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    WeightedSpatialData(spatialdata, weights)

Assign `weights` for each point in `spatialdata`.
"""
struct WeightedSpatialData{T,N,S<:AbstractData{T,N},V} <: AbstractData{T,N}
  spatialdata::S
  weights::Vector{V}
end

domain(d::WeightedSpatialData) = domain(d.spatialdata)

variables(d::WeightedSpatialData) = variables(d.spatialdata)

Base.getindex(d::WeightedSpatialData, ind::Int, var::Symbol) =
  getindex(d.spatialdata, ind, var)

"""
    AbstractWeighter

A method to weight spatial data.
"""
abstract type AbstractWeighter end

"""
    weight(spatialdata, weighter)

Weight `spatialdata` with `weighter` method.
"""
weight(spatialdata::AbstractData, weighter::AbstractWeighter) = error("not implemented")

#------------------
# IMPLEMENTATIONS
#------------------
include("weighting/block_weighter.jl")

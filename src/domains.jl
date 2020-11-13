# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain

An abstract type to aid with custom spatial domain types. Users
can subtype their domains from this type, and implement the methods
in `geotraits/domain.jl`.
"""
abstract type AbstractDomain end

"""
    view(domain, inds)

Return a view of `domain` at given indices `inds`.
"""
Base.view(domain::AbstractDomain, inds::AbstractVector{Int}) =
  DomainView(domain, inds)

#------------------
# IMPLEMENTATIONS
#------------------
"""
    SpatialDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type SpatialDomain{T,N} <: AbstractDomain end

ncoords(::SpatialDomain{T,N}) where {T,N} = N
coordtype(::SpatialDomain{T,N}) where {T,N} = T

include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")
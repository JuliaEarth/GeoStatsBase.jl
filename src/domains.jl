# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractDomain{T,N} end

geotrait(::AbstractDomain) = GeoDomain()
ncoords(::AbstractDomain{T,N}) where {T,N} = N
coordtype(::AbstractDomain{T,N}) where {T,N} = T

"""
    view(domain, inds)

Return a view of `domain` at given indices `inds`.
"""
Base.view(domain::AbstractDomain, inds::AbstractVector{Int}) =
  SpatialDomainView(domain, inds)

#------------------
# IMPLEMENTATIONS
#------------------
include("domains/curve.jl")
include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")
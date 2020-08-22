# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type SpatialDomain{T,N} end

geotrait(::SpatialDomain) = GeoDomain()
ncoords(::SpatialDomain{T,N}) where {T,N} = N
coordtype(::SpatialDomain{T,N}) where {T,N} = T

"""
    view(domain, inds)

Return a view of `domain` at given indices `inds`.
"""
Base.view(domain::SpatialDomain, inds::AbstractVector{Int}) =
  SpatialDomainView(domain, inds)

#------------------
# IMPLEMENTATIONS
#------------------
include("domains/curve.jl")
include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")
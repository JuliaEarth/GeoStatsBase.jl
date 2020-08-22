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
    view(domain, locations)

Return a view of `domain` with all points in `locations`.
"""
Base.view(domain::AbstractDomain,
          locations::AbstractVector{Int}) = DomainView(domain, locations)

# ------------
# IO methods
# ------------
function Base.show(io::IO, domain::AbstractDomain{T,N}) where {N,T}
  n = nelms(domain)
  print(io, "$n SpatialDomain{$T,$N}")
end

#------------------
# IMPLEMENTATIONS
#------------------
include("domains/curve.jl")
include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")
# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractDomain{T<:Real,N} <: AbstractSpatialObject{T,N} end

"""
    view(domain, locations)

Return a view of `domain` with all points in `locations`.
"""
Base.view(domain::AbstractDomain,
          locations::AbstractVector{Int}) = DomainView(domain, locations)

# ------------
# IO methods
# ------------
function Base.show(io::IO, domain::AbstractDomain{T,N}) where {N,T<:Real}
  npts = npoints(domain)
  print(io, "$npts SpatialDomain{$T,$N}")
end

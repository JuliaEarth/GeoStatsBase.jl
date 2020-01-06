# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractDomain{T,N} <: AbstractSpatialObject{T,N} end

"""
    georef(domain, data)

Georeference a dictionary with raw `data` on a spatial `domain`.
"""
georef(data::Dict{Symbol,<:AbstractArray}, domain::AbstractDomain) =
  PointSetData(data, coordinates(domain))

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
  npts = npoints(domain)
  print(io, "$npts SpatialDomain{$T,$N}")
end

#------------------
# IMPLEMENTATIONS
#------------------
include("domains/curve.jl")
include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")

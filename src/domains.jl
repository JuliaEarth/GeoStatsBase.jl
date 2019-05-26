# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain{T,N}

A spatial domain with `N` dimensions in which
points are represented with coordinates of type `T`.
"""
abstract type AbstractDomain{T<:Real,N} end

"""
    ndims(domain)

Return the number of dimensions of a spatial domain.
"""
Base.ndims(::AbstractDomain{T,N}) where {N,T<:Real} = N

"""
    coordtype(domain)

Return the coordinate type of a spatial domain.
"""
coordtype(::AbstractDomain{T,N}) where {N,T<:Real} = T

"""
    npoints(domain)

Return the number of points of a spatial domain.
"""
npoints(::AbstractDomain) = error("not implemented")

"""
    coordinates(domain, location)

Return the coordinates of the `location` in the `domain`.
"""
function coordinates(domain::AbstractDomain{T,N},
                     location::Int) where {N,T<:Real}
  x = MVector{N,T}(undef)
  coordinates!(x, domain, location)
  x
end

"""
    coordinates(domain, locations)

Return the coordinates of `locations` in the `domain`.
"""
function coordinates(domain::AbstractDomain{T,N},
                     locations::AbstractVector{Int}) where {N,T<:Real}
  X = Matrix{T}(undef, N, length(locations))
  coordinates!(X, domain, locations)
  X
end

"""
    coordinates(domain)

Return the coordinates of all locations in `domain`.
"""
coordinates(domain::AbstractDomain) = coordinates(domain, 1:npoints(domain))

"""
    coordinates!(buff, domain, locations)

Non-allocating version of [`coordinates`](@ref)
"""
function coordinates!(buff::AbstractMatrix, domain::AbstractDomain,
                      locations::AbstractVector{Int})
  for j in 1:length(locations)
    coordinates!(view(buff,:,j), domain, locations[j])
  end
end

"""
    coordinates!(buff, domain, location)

Non-allocating version of [`coordinates`](@ref).
"""
coordinates!(::AbstractVector, ::AbstractDomain, ::Int) = error("not implemented")

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

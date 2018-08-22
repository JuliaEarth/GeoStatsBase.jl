# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
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
function coordinates(domain::AbstractDomain{T,N}, location::Int) where {N,T<:Real}
  coords = MVector{N,T}(undef)
  coordinates!(coords, domain, location)
  coords
end

"""
    coordinates!(buff, domain, location)

Non-allocating version of [`coordinates`](@ref).
"""
coordinates!(::AbstractVector, ::AbstractDomain, ::Int) = error("not implemented")

"""
    nearestlocation(domain, coords)

Return the nearest location of `coords` in the `domain`.
"""
function nearestlocation(domain::AbstractDomain{T,N},
                         coords::AbstractVector{T}) where {T<:Real,N}
  lmin, dmin = 0, Inf
  c = MVector{N,T}(undef)
  for l in 1:npoints(domain)
    coordinates!(c, domain, l)
    d = norm(coords - c)
    d < dmin && ((lmin, dmin) = (l, d))
  end

  lmin
end

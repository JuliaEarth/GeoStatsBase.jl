# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSpatialObject{T,N}

Spatial object in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractSpatialObject{T<:Real,N} end

"""
    domain(object)

Return underlying domain of spatial `object`.
"""
domain(object) = object.domain

"""
    ndims(object)

Return the number of dimensions of domain underlying `object`.
"""
Base.ndims(::AbstractSpatialObject{T,N}) where {N,T<:Real} = N

"""
    coordtype(object)

Return the coordinate type of `object`.
"""
coordtype(::AbstractSpatialObject{T,N}) where {N,T<:Real} = T

"""
    coordnames(object)

Return the name of the coordinates in `object`.
"""
coordnames(object::AbstractSpatialObject{T,N}) where {N,T<:Real} = ntuple(i -> Symbol(:x,i), N)

"""
    npoints(object)

Return the number of points in `object`.
"""
npoints(object::AbstractSpatialObject) = npoints(domain(object))

"""
    coordinates(object, location)

Return the coordinates of the `location` in the `object`.
"""
function coordinates(object::AbstractSpatialObject{T,N},
                     location::Int) where {N,T<:Real}
  x = MVector{N,T}(undef)
  coordinates!(x, object, location)
  x
end

"""
    coordinates(object, locations)

Return the coordinates of `locations` in the `object`.
"""
function coordinates(object::AbstractSpatialObject{T,N},
                     locations::AbstractVector{Int}) where {N,T<:Real}
  X = Matrix{T}(undef, N, length(locations))
  coordinates!(X, object, locations)
  X
end

"""
    coordinates(object)

Return the coordinates of all locations in `object`.
"""
coordinates(object::AbstractSpatialObject) = coordinates(object, 1:npoints(object))

"""
    coordinates!(buff, object, locations)

Non-allocating version of [`coordinates`](@ref)
"""
function coordinates!(buff::AbstractMatrix, object::AbstractSpatialObject,
                      locations::AbstractVector{Int})
  for j in 1:length(locations)
    coordinates!(view(buff,:,j), object, locations[j])
  end
end

"""
    coordinates!(buff, object, location)

Non-allocating version of [`coordinates`](@ref).
"""
coordinates!(buff::AbstractVector, object::AbstractSpatialObject, location::Int) =
  coordinates!(buff, domain(object), location)

"""
    coordextrema(object)

Return the extrema of the coordinates of the `object`.
"""
function coordextrema(object::AbstractSpatialObject{T,N}) where {N,T<:Real}
  lowerleft  = MVector(ntuple(i->typemax(T), N))
  upperright = MVector(ntuple(i->typemin(T), N))

  x = MVector{N,T}(undef)
  for l in 1:npoints(object)
    coordinates!(x, object, l)
    for d in 1:N
      x[d] < lowerleft[d]  && (lowerleft[d]  = x[d])
      x[d] > upperright[d] && (upperright[d] = x[d])
    end
  end

  lowerleft, upperright
end

"""
    nearestlocation(object, coords)

Return the nearest location of `coords` in the `object`.
"""
function nearestlocation(object::AbstractSpatialObject{T,N},
                         coords::AbstractVector{T}) where {N,T<:Real}
  lmin, dmin = 0, Inf
  c = MVector{N,T}(undef)
  for l in 1:npoints(object)
    coordinates!(c, object, l)
    d = norm(coords - c)
    d < dmin && ((lmin, dmin) = (l, d))
  end

  lmin
end

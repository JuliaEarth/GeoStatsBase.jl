# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeoCollection

An indexable collection of georeferenced elements.
"""
abstract type GeoCollection end

"""
    GeoDomain

A [`GeoCollection`](@ref) that represents geospatial domains.

## Traits

* [`ndims`](@ref)       - number of dimensions
* [`npoints`](@ref)     - number of elements
* [`coordtype`](@ref)   - coordinate type
* [`coordinate!`](@ref) - coordinates
"""
struct GeoDomain <: GeoCollection end

"""
    GeoData

A [`GeoCollection`](@ref) that represents geospatial data, i.e.
a geospatial `domain` together with a data table of `values`.

## Traits

* [`domain`](@ref)      - spatial domain
* [`values`](@ref)      - data table
"""
struct GeoData <: GeoCollection end

"""
    geotype(object)

Return the geospatial type of the `object`.
"""
geotype

"""
    ndims(object)

Return the number of dimensions of `object`.
"""
ndims

"""
    coordtype(object)

Return the coordinate type of `object`.
"""
coordtype(obj) = coordtype(geotype(obj), obj)
coordtype(::GeoData, obj) = coordtype(domain(obj))

"""
    domain(object)

Return underlying domain of the `object`.
"""
domain

"""
    values(data)

Return the values of geospatial `data` as a table.
"""
values

"""
    npoints(object)

Return the number of points in `object`.
"""
npoints(obj) = npoints(geotype(obj), obj)
npoints(::GeoCollection, obj) = npoints(domain(obj))

"""
    coordinates!(buff, object, ind)

Non-allocating version of [`coordinates`](@ref).
"""
coordinates!(buff::AbstractVector, obj, ind::Int) =
  coordinates!(geotype(obj), buff, obj, ind)
coordinates!(::GeoCollection, buff, obj, ind) =
  coordinates!(buff, domain(obj), ind)

"""
    coordinates!(buff, object, inds)

Non-allocating version of [`coordinates`](@ref)
"""
function coordinates!(buff::AbstractMatrix, obj, inds::AbstractVector{Int})
  for j in 1:length(inds)
    coordinates!(view(buff,:,j), obj, inds[j])
  end
end

"""
    coordinates(object, ind)

Return the coordinates of the `ind` in the `object`.
"""
function coordinates(obj, ind::Int)
  N = ndims(obj)
  T = coordtype(obj)
  x = MVector{N,T}(undef)
  coordinates!(x, obj, ind)
  x
end

"""
    coordinates(object, inds)

Return the coordinates of `inds` in the `object`.
"""
function coordinates(obj, inds::AbstractVector{Int})
  N = ndims(obj)
  T = coordtype(obj)
  X = Matrix{T}(undef, N, length(inds))
  coordinates!(X, obj, inds)
  X
end

"""
    coordinates(object)

Return the coordinates of all indices in `object`.
"""
coordinates(obj) = coordinates(obj, 1:npoints(obj))
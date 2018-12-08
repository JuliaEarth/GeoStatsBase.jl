# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSpatialData{T,N}

Spatial data distributed in a `N`-dimensional
space using coordinates of type `T`.
"""
abstract type AbstractSpatialData{T<:Real,N} end

"""
    ndims(spatialdata)

Return the number of dimensions of domain underlying `spatialdata`.
"""
Base.ndims(::AbstractSpatialData{T,N}) where {N,T<:Real} = N

"""
    coordtype(spatialdata)

Return the coordinate type of a spatial data.
"""
coordtype(::AbstractSpatialData{T,N}) where {N,T<:Real} = T

"""
    valuetype(spatialdata, var)

Return the value type of `var` in `spatialdata`.
"""
valuetype(spatialdata::AbstractSpatialData, var::Symbol) = variables(spatialdata)[var]

"""
    coordinates(spatialdata)

Return the name of the coordinates in `spatialdata` and their types.
"""
coordinates(::AbstractSpatialData) = error("not implemented")

"""
    variables(spatialdata)

Return the variable names in `spatialdata` and their types.
"""
variables(::AbstractSpatialData) = error("not implemented")

"""
    npoints(spatialdata)

Return the number of points in `spatialdata`.
"""
npoints(::AbstractSpatialData) = error("not implemented")

"""
    coordinates(spatialdata, ind)

Return the coordinates of the `ind`-th point in `spatialdata`.
"""
function coordinates(spatialdata::AbstractSpatialData{T,N}, ind::Int) where {N,T<:Real}
  coords = MVector{N,T}(undef)
  coordinates!(coords, spatialdata, ind)
  coords
end

"""
    coordinates!(buff, spatialdata, ind)

Non-allocating version of [`coordinates`](@ref).
"""
coordinates!(::AbstractVector, ::AbstractSpatialData, ::Int) = error("not implemented")

"""
    value(spatialdata, ind, var)

Return the value of `var` for the `ind`-th point in `spatialdata`.
"""
value(::AbstractSpatialData, ::Int, ::Symbol) = error("not implemented")

"""
    isvalid(spatialdata, ind, var)

Return `true` if the `ind`-th point in `spatialdata` has a valid value for `var`.
"""
function Base.isvalid(spatialdata::AbstractSpatialData, ind::Int, var::Symbol)
  val = value(spatialdata, ind, var)
  !(val ≡ missing || (val isa Number && isnan(val)))
end

"""
    valid(spatialdata, var)

Return all points in `spatialdata` with a valid value for `var`. The output
is a tuple with the matrix of coordinates as the first item and the vector
of values as the second item.
"""
function valid(spatialdata::AbstractSpatialData, var::Symbol)
  # determine coordinate and value type
  T = coordtype(spatialdata)
  V = valuetype(spatialdata, var)

  # provide size hint for output
  xs = Vector{Vector{T}}(); zs = Vector{V}()
  sizehint!(xs, npoints(spatialdata))
  sizehint!(zs, npoints(spatialdata))

  for location in 1:npoints(spatialdata)
    if isvalid(spatialdata, location, var)
      push!(xs, coordinates(spatialdata, location))
      push!(zs, value(spatialdata, location, var))
    end
  end

  # return matrix and vector
  hcat(xs...), zs
end

"""
    view(spatialdata, inds)

Return a view of `spatialdata` with all points in `inds` locations.
"""
Base.view(spatialdata::AbstractSpatialData, inds::AbstractVector{Int}) = error("not implemented")

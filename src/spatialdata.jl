# ------------------------------------------------------------------
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
    coordnames(spatialdata)

Return the name of the coordinates in `spatialdata`.
"""
coordnames(spatialdata::AbstractSpatialData{T,N}) where {N,T<:Real} = ntuple(i -> Symbol(:x,i), N)

"""
    valuetype(spatialdata, var)

Return the value type of `var` in `spatialdata`.
"""
valuetype(spatialdata::AbstractSpatialData, var::Symbol) = variables(spatialdata)[var]

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
    coordinates(spatialdata, inds)

Return the coordinates of `inds` in the `spatialdata`.
"""
function coordinates(spatialdata::AbstractSpatialData{T,N},
                     inds::AbstractVector{Int}) where {N,T<:Real}
  X = Matrix{T}(undef, N, length(inds))
  coordinates!(X, spatialdata, inds)
  X
end

"""
    coordinates(spatialdata)

Return the coordinates of all indices in `spatialdata`.
"""
coordinates(spatialdata::AbstractSpatialData) = coordinates(spatialdata, 1:npoints(spatialdata))

"""
    coordinates!(buff, spatialdata, indices)

Non-allocating version of [`coordinates`](@ref)
"""
function coordinates!(buff::AbstractMatrix, spatialdata::AbstractSpatialData,
                      indices::AbstractVector{Int})
  for j in 1:length(indices)
    coordinates!(view(buff,:,j), spatialdata, indices[j])
  end
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
    values(spatialdata, var)

Return the values of `var` for all the points in `spatialdata`.
"""
Base.values(spatialdata::AbstractSpatialData, var::Symbol) =
  [value(spatialdata, ind, var) for ind in 1:npoints(spatialdata)]

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
function valid(spatialdata::AbstractSpatialData{T,N}, var::Symbol) where {N,T<:Real}
  # determine coordinate and value type
  V = valuetype(spatialdata, var)
  npts = npoints(spatialdata)

  # pre-allocate memory for result
  X = Matrix{T}(undef, N, npts)
  z = Vector{V}(undef, npts)

  nvalid = 0
  for ind in 1:npoints(spatialdata)
    if isvalid(spatialdata, ind, var)
      nvalid += 1
      coordinates!(view(X,:,nvalid), spatialdata, ind)
      z[nvalid] = value(spatialdata, ind, var)
    end
  end

  X[:,1:nvalid], z[1:nvalid]
end

"""
    view(spatialdata, inds)

Return a view of `spatialdata` with all points in `inds`.
"""
Base.view(spatialdata::AbstractSpatialData,
          inds::AbstractVector{Int}) = SpatialDataView(spatialdata, inds)

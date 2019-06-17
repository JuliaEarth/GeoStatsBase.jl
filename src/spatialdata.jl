# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSpatialData{T,N}

Spatial data in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractSpatialData{T,N} <: AbstractSpatialObject{T,N} end

"""
    valuetype(spatialdata, var)

Return the value type of `var` in `spatialdata`.
"""
valuetype(spatialdata::AbstractSpatialData, var::Symbol) = variables(spatialdata)[var]

"""
    variables(spatialdata)

Return the variable names in `spatialdata` and their types.
"""
variables(spatialdata::AbstractSpatialData) = Dict(var => eltype(array) for (var,array) in spatialdata.data)

"""
    value(spatialdata, ind, var)

Return the value of `var` for the `ind`-th point in `spatialdata`.
"""
value(spatialdata::AbstractSpatialData, ind::Int, var::Symbol) = spatialdata.data[var][ind]

"""
    values(spatialdata, var)

Return the values of `var` for all the points in `spatialdata`.
"""
Base.values(spatialdata::AbstractSpatialData, var::Symbol) =
  [value(spatialdata, ind, var) for ind in 1:npoints(spatialdata)]

"""
    values(spatialdata)

Return the values of all variables in `spatialdata`.
"""
Base.values(spatialdata::AbstractSpatialData) =
  Dict(var => values(spatialdata, var) for (var,V) in variables(spatialdata))

"""
    spatialdata[var]

Return `values(spatialdata, var)` with the correct shape of the underlying domain.
"""
Base.getindex(spatialdata::AbstractSpatialData, var::Symbol) = values(spatialdata, var)

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
function valid(spatialdata::AbstractSpatialData{T,N}, var::Symbol) where {N,T}
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

# ------------
# IO methods
# ------------
function Base.show(io::IO, spatialdata::AbstractSpatialData{T,N}) where {N,T}
  npts = npoints(spatialdata)
  print(io, "$npts SpatialData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", spatialdata::AbstractSpatialData{T,N}) where {N,T}
  println(io, spatialdata)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(spatialdata)]
  print(io, join(varlines, "\n"))
end

#------------------
# IMPLEMENTATIONS
#------------------
include("spatialdata/geodataframe.jl")
include("spatialdata/point_set_data.jl")
include("spatialdata/regular_grid_data.jl")
include("spatialdata/structured_grid_data.jl")

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractData{T,N}

Spatial data in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractData{T,N} <: AbstractSpatialObject{T,N} end

"""
    variables(spatialdata)

Return the variable names in `spatialdata` and their types.
"""
variables(spatialdata::AbstractData) =
  Dict(var => eltype(array) for (var,array) in spatialdata.data)

"""
    spatialdata[ind,var]
    spatialdata[inds,vars]

Return the value of `var` for the `ind`-th point in `spatialdata`.
"""
Base.getindex(spatialdata::AbstractData, ind::Int, var::Symbol) =
  spatialdata.data[var][ind]

Base.getindex(spatialdata::AbstractData, inds::AbstractVector{Int}, var::Symbol) =
  [getindex(spatialdata, ind, var) for ind in inds]

Base.getindex(spatialdata::AbstractData, ind::Int, vars::AbstractVector{Symbol}) =
  [getindex(spatialdata, ind, var) for var in vars]

Base.getindex(spatialdata::AbstractData, inds::AbstractVector{Int}, vars::AbstractVector{Symbol}) =
  [getindex(spatialdata, ind, var) for ind in inds, var in vars]

"""
    spatialdata[var]

Return the values of `var` for all points in `spatialdata` with the shape
of the underlying domain.
"""
Base.getindex(spatialdata::AbstractData, var::Symbol) =
  [getindex(spatialdata, ind, var) for ind in 1:npoints(spatialdata)]

"""
    view(spatialdata, inds)
    view(spatialdata, vars)
    view(spatialdata, inds, vars)

Return a view of `spatialdata` with all points in `inds` and
all variables in `vars`.
"""
Base.view(sdata::AbstractData, inds::AbstractVector{Int}) =
  DataView(sdata, inds, collect(keys(variables(sdata))))

Base.view(sdata::AbstractData, vars::AbstractVector{Symbol}) =
  DataView(sdata, 1:npoints(sdata), vars)

Base.view(sdata::AbstractData, inds::AbstractVector{Int},
                               vars::AbstractVector{Symbol}) =
  DataView(sdata, inds, vars)

#----------------
# TABLES.JL API
#----------------
Tables.istable(::Type{<:AbstractData}) = true

Tables.columnaccess(::Type{<:AbstractData}) = true

function Tables.columns(spatialdata::AbstractData)
  vars = keys(variables(spatialdata))
  vals = [getindex(spatialdata, 1:npoints(spatialdata), var) for var in vars]
  NamedTuple{tuple(vars...)}(vals)
end

#-----------------
# MISSING VALUES
#-----------------
"""
    isvalid(spatialdata, ind, var)

Return `true` if the `ind`-th point in `spatialdata` has a valid value for `var`.
"""
function Base.isvalid(spatialdata::AbstractData, ind::Int, var::Symbol)
  val = getindex(spatialdata, ind, var)
  !(val ≡ missing || (val isa Number && isnan(val)))
end

"""
    valid(spatialdata, var)

Return all points in `spatialdata` with a valid value for `var`. The output
is a tuple with the matrix of coordinates as the first item and the vector
of values as the second item.
"""
function valid(spatialdata::AbstractData{T,N}, var::Symbol) where {N,T}
  V = variables(spatialdata)[var]
  npts = npoints(spatialdata)

  # pre-allocate memory for result
  X = Matrix{T}(undef, N, npts)
  z = Vector{V}(undef, npts)

  nvalid = 0
  for ind in 1:npoints(spatialdata)
    if isvalid(spatialdata, ind, var)
      nvalid += 1
      coordinates!(view(X,:,nvalid), spatialdata, ind)
      z[nvalid] = getindex(spatialdata, ind, var)
    end
  end

  X[:,1:nvalid], z[1:nvalid]
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, spatialdata::AbstractData{T,N}) where {N,T}
  npts = npoints(spatialdata)
  print(io, "$npts SpatialData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", spatialdata::AbstractData{T,N}) where {N,T}
  println(io, spatialdata)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(spatialdata)]
  print(io, join(sort(varlines), "\n"))
end

#------------------
# IMPLEMENTATIONS
#------------------
include("data/curve_data.jl")
include("data/geodataframe.jl")
include("data/point_set_data.jl")
include("data/regular_grid_data.jl")
include("data/structured_grid_data.jl")

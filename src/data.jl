# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractData{T,N}

Spatial data in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractData{T,N} <: AbstractSpatialObject{T,N} end

"""
    variables(sdata)

Return the variable names in spatial data `sdata` and their types.
"""
variables(sdata::AbstractData) =
  Dict(var => eltype(array) for (var,array) in sdata.data)

#----------------
# DATAFRAME API
#----------------

"""
    sdata[inds,vars]

Return the value of `var` for the `ind`-th point in `sdata`.
"""
Base.getindex(sdata::AbstractData, ind::Int, var::Symbol) =
  sdata.data[var][ind]

Base.getindex(sdata::AbstractData, inds::AbstractVector{Int}, var::Symbol) =
  [getindex(sdata, ind, var) for ind in inds]

Base.getindex(sdata::AbstractData, ind::Int, vars::AbstractVector{Symbol}) =
  [getindex(sdata, ind, var) for var in vars]

Base.getindex(sdata::AbstractData, inds::AbstractVector{Int}, vars::AbstractVector{Symbol}) =
  [getindex(sdata, ind, var) for ind in inds, var in vars]

"""
    sdata[var]

Return the values of `var` for all points in `sdata` with the shape
of the underlying domain.
"""
Base.getindex(sdata::AbstractData, var::Symbol) =
  [getindex(sdata, ind, var) for ind in 1:npoints(sdata)]

Base.getindex(sdata::AbstractData, vars::AbstractVector{Symbol}) =
  [getindex(sdata, var) for var in vars]

#-----------
# VIEW API
#-----------

"""
    view(sdata, inds)
    view(sdata, vars)
    view(sdata, inds, vars)

Return a view of `sdata` with all points in `inds` and
all variables in `vars`.
"""
Base.view(sdata::AbstractData, inds::AbstractVector{Int}) =
  DataView(sdata, inds, collect(keys(variables(sdata))))

Base.view(sdata::AbstractData, vars::AbstractVector{Symbol}) =
  DataView(sdata, 1:npoints(sdata), vars)

Base.view(sdata::AbstractData, inds::AbstractVector{Int},
                               vars::AbstractVector{Symbol}) =
  DataView(sdata, inds, vars)

#---------------
# ITERATOR API
#---------------

"""
    iterate(sdata, state=1)

Iterate over samples in `sdata`.
"""
Base.iterate(sdata::AbstractData, state=1) =
  state > npoints(sdata) ? nothing : (sdata[state], state + 1)

"""
    length(sdata)

Return the number of samples in `sdata`.
"""
Base.length(sdata::AbstractData) = npoints(sdata)

#----------------
# INDEXABLE API
#----------------

"""
    getindex(sdata, ind)

Return `ind`-th sample in `sdata`.
"""
function Base.getindex(sdata::AbstractData, ind::Int)
  vars = [var for (var,V) in variables(sdata)]
  vals = [getindex(sdata, ind, var) for var in vars]
  NamedTuple{tuple(vars...)}(vals)
end

Base.getindex(sdata::AbstractData, inds::AbstractVector{Int}) =
  [getindex(sdata, ind) for ind in inds]

"""
    firstindex(sdata)

Return the first index of `sdata`.
"""
Base.firstindex(sdata::AbstractData) = 1

"""
    lastindex(sdata)

Return the last index of `sdata`.
"""
Base.lastindex(sdata::AbstractData) = npoints(sdata)

#-------------
# TABLES API
#-------------
Tables.istable(::Type{<:AbstractData}) = true

Tables.columnaccess(::Type{<:AbstractData}) = true

function Tables.columns(sdata::AbstractData)
  vars = keys(variables(sdata))
  vals = [getindex(sdata, 1:npoints(sdata), var) for var in vars]
  NamedTuple{tuple(vars...)}(vals)
end

#-----------------
# MISSING VALUES
#-----------------
"""
    isvalid(sdata, ind, var)

Return `true` if the `ind`-th point in `sdata` has a valid value for `var`.
"""
function Base.isvalid(sdata::AbstractData, ind::Int, var::Symbol)
  val = getindex(sdata, ind, var)
  !(ismissing(val) || (val isa Number && isnan(val)))
end

"""
    valid(sdata, var)

Return all points in `sdata` with a valid value for `var`. The output is
a tuple with the matrix of coordinates as the first item and the vector
of values as the second item.
"""
function valid(sdata::AbstractData{T,N}, var::Symbol) where {N,T}
  V = variables(sdata)[var]
  npts = npoints(sdata)

  # pre-allocate memory for result
  X = Matrix{T}(undef, N, npts)
  z = Vector{V}(undef, npts)

  nvalid = 0
  for ind in 1:npoints(sdata)
    if isvalid(sdata, ind, var)
      nvalid += 1
      coordinates!(view(X,:,nvalid), sdata, ind)
      z[nvalid] = getindex(sdata, ind, var)
    end
  end

  X[:,1:nvalid], z[1:nvalid]
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, sdata::AbstractData{T,N}) where {N,T}
  npts = npoints(sdata)
  print(io, "$npts SpatialData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", sdata::AbstractData{T,N}) where {N,T}
  println(io, sdata)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(sdata)]
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

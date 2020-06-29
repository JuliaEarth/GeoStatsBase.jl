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
variables(sdata::AbstractData) = Variables(sdata.data)

# --------------
# DATAFRAME API
# --------------

"""
    getindex(sdata, inds, vars)

Return the value of `vars` for the `inds` points in `sdata`.
"""
Base.getindex(sdata::AbstractData, inds, vars) =
  getindex(sdata.data, inds, vars)

"""
    setindex!(sdata, vals, inds, vars)

Set the value `vals` of variables `vars` for points `inds` in `sdata`.
"""
Base.setindex!(sdata::AbstractData, vals, inds, vars) =
  setindex!(sdata.data, vals, inds, vars)

# -------------
# VARIABLE API
# -------------

"""
    getindex(sdata, var)

Return the values of variable `var` in `sdata`.
"""
Base.getindex(sdata::AbstractData, var::Symbol) = sdata.data[!,var]

# ---------
# VIEW API
# ---------

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

# -------------
# ITERATOR API
# -------------

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

"""
    eltype(sdata)

Return the element type of `sdata`.
"""
Base.eltype(sdata::AbstractData) = eltype(eachrow(sdata.data))


#----------------
# INDEXABLE API
#----------------

"""
    getindex(sdata, ind)

Return `ind`-th sample in `sdata`.
"""
Base.getindex(sdata::AbstractData, ind::Int) =
  eachrow(sdata.data)[ind]

Base.getindex(sdata::AbstractData, inds::AbstractVector{Int}) =
  eachrow(sdata.data)[inds]

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

Tables.rowaccess(::Type{<:AbstractData}) = true
Tables.columnaccess(::Type{<:AbstractData}) = true

Tables.rows(sdata::AbstractData) = Tables.rows(sdata.data)
Tables.columns(sdata::AbstractData) = Tables.columns(sdata.data)

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
include("data/simple_data.jl")
include("data/geodataframe.jl")

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
variables(sdata::AbstractData) = Variables(sdata.table)

"""
    values(sdata)

Return the values of spatial data `sdata` as a table.
"""
Base.values(sdata::AbstractData) = sdata.table

# --------------
# DATAFRAME API
# --------------

Base.getindex(sdata::AbstractData, inds, vars) =
  getindex(sdata.table, inds, vars)
Base.setindex!(sdata::AbstractData, vals, inds, vars) =
  setindex!(sdata.table, vals, inds, vars)

# -------------
# VARIABLE API
# -------------

Base.getindex(sdata::AbstractData, var::Symbol) =
  getindex(sdata.table, :, var)
Base.setindex!(sdata::AbstractData, vals, var::Symbol) =
  setindex!(sdata.table, vals, :, var)

# ---------
# VIEW API
# ---------

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

Base.iterate(sdata::AbstractData, state=1) =
  state > npoints(sdata) ? nothing : (sdata[state], state + 1)
Base.length(sdata::AbstractData) = npoints(sdata)
Base.eltype(sdata::AbstractData) = typeof(sdata[1])

# --------------
# INDEXABLE API
# --------------

Base.getindex(sdata::AbstractData, ind::Int) =
  getindex(sdata.table, ind, :)
Base.getindex(sdata::AbstractData, inds::AbstractVector{Int}) =
  getindex(sdata.table, inds, :)
Base.firstindex(sdata::AbstractData) = 1
Base.lastindex(sdata::AbstractData) = npoints(sdata)

# -----------
# TABLES API
# -----------
Tables.istable(::Type{<:AbstractData}) = true
Tables.rowaccess(sdata::AbstractData) = Tables.rowaccess(sdata.table)
Tables.columnaccess(sdata::AbstractData) = Tables.columnaccess(sdata.table)
Tables.rows(sdata::AbstractData) = Tables.rows(sdata.table)
Tables.columns(sdata::AbstractData) = Tables.columns(sdata.table)

# ---------------
# MISSING VALUES
# ---------------
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
  println(io, domain(sdata))
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(sdata)]
  print(io, join(sort(varlines), "\n"))
end

# ----------------
# IMPLEMENTATIONS
# ----------------
"""
    SpatialData(domain, data)

Tabular `data` georeferenced in a spatial `domain`.
"""
struct SpatialData{T,N,𝒟,𝒯} <: AbstractData{T,N}
  domain::𝒟
  table::𝒯
end

function SpatialData(domain, table)
  nd = npoints(domain)
  nt = length(Tables.rows(table))
  @assert nd == nt "number of rows ≠ number of points"
  T = coordtype(domain)
  N = ndims(domain)
  𝒟 = typeof(domain)
  𝒯 = typeof(table)
  SpatialData{T,N,𝒟,𝒯}(domain, table)
end

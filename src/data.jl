# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractData{T,N}

Spatial data in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractData{T,N} end

geotype(::AbstractData) = GeoData()
ndims(::AbstractData{T,N}) where {T,N} = N
domain(data::AbstractData) = data.domain
values(data::AbstractData) = data.table

"""
    variables(data)

Return the variable names in geospatial `data` and their types.
"""
variables(data::AbstractData) = variables(data.table)

# -----------
# TABLES API
# -----------

Tables.istable(::Type{<:AbstractData}) = true
Tables.schema(sdata::AbstractData) = Tables.schema(sdata.table)
Tables.rowaccess(sdata::AbstractData) = Tables.rowaccess(sdata.table)
Tables.columnaccess(sdata::AbstractData) = Tables.columnaccess(sdata.table)
Tables.rows(sdata::AbstractData) = Tables.rows(sdata.table)
Tables.columns(sdata::AbstractData) = Tables.columns(sdata.table)
Tables.columnnames(sdata::AbstractData) = Tables.columnnames(sdata.table)
Tables.getcolumn(sdata::AbstractData, c::Symbol) = Tables.getcolumn(sdata.table, c)

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
Base.firstindex(sdata::AbstractData) = 1
Base.lastindex(sdata::AbstractData) = npoints(sdata)

# ---------
# VIEW API
# ---------

Base.view(sdata::AbstractData, inds::AbstractVector{Int}) =
  DataView(sdata, inds, collect(name.(variables(sdata))))
Base.view(sdata::AbstractData, vars::AbstractVector{Symbol}) =
  DataView(sdata, 1:npoints(sdata), vars)
Base.view(sdata::AbstractData, inds, vars) =
  DataView(sdata, inds, vars)

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
  varlines = ["    └─$(name(var)) ($(mactype(var)))" for var in variables(sdata)]
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

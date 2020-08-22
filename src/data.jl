# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialData(domain, data)

Tabular `data` georeferenced in a spatial `domain`.
"""
struct SpatialData{𝒟,𝒯}
  domain::𝒟
  table::𝒯

  function SpatialData{𝒟,𝒯}(domain, table) where {𝒟,𝒯}
    ne = nelms(domain)
    nr = length(Tables.rows(table))
    @assert ne == nr "number of rows ≠ number of points"
    new(domain, table)
  end
end

SpatialData(domain::𝒟, table::𝒯) where {𝒟,𝒯} =
  SpatialData{𝒟,𝒯}(domain, table)

geotrait(::SpatialData)    = GeoData()
domain(sdata::SpatialData) = sdata.domain
values(sdata::SpatialData) = sdata.table

# -----------
# TABLES API
# -----------

Tables.istable(::Type{<:SpatialData}) = true
Tables.schema(sdata::SpatialData) = Tables.schema(sdata.table)
Tables.rowaccess(sdata::SpatialData) = Tables.rowaccess(sdata.table)
Tables.columnaccess(sdata::SpatialData) = Tables.columnaccess(sdata.table)
Tables.rows(sdata::SpatialData) = Tables.rows(sdata.table)
Tables.columns(sdata::SpatialData) = Tables.columns(sdata.table)
Tables.columnnames(sdata::SpatialData) = Tables.columnnames(sdata.table)
Tables.getcolumn(sdata::SpatialData, c::Symbol) = Tables.getcolumn(sdata.table, c)

# --------------
# DATAFRAME API
# --------------

Base.getindex(sdata::SpatialData, inds, vars) =
  getindex(sdata.table, inds, vars)
Base.setindex!(sdata::SpatialData, vals, inds, vars) =
  setindex!(sdata.table, vals, inds, vars)

# -------------
# VARIABLE API
# -------------

variables(sdata::SpatialData) = variables(sdata.table)

Base.getindex(sdata::SpatialData, var::Symbol) =
  getindex(sdata.table, :, var)
Base.setindex!(sdata::SpatialData, vals, var::Symbol) =
  setindex!(sdata.table, vals, :, var)

# -------------
# ITERATOR API
# -------------

Base.iterate(sdata::SpatialData, state=1) =
  state > nelms(sdata) ? nothing : (sdata[state], state + 1)
Base.length(sdata::SpatialData) = nelms(sdata)
Base.eltype(sdata::SpatialData) = typeof(sdata[1])

# --------------
# INDEXABLE API
# --------------

Base.getindex(sdata::SpatialData, ind::Int) =
  getindex(sdata.table, ind, :)
Base.firstindex(sdata::SpatialData) = 1
Base.lastindex(sdata::SpatialData)  = nelms(sdata)

# ---------
# VIEW API
# ---------

Base.view(sdata::SpatialData, inds::AbstractVector{Int}) =
  SpatialDataView(sdata, inds, collect(name.(variables(sdata))))
Base.view(sdata::SpatialData, vars::AbstractVector{Symbol}) =
  SpatialDataView(sdata, 1:nelms(sdata), vars)
Base.view(sdata::SpatialData, inds, vars) =
  SpatialDataView(sdata, inds, vars)

# ------------
# IO methods
# ------------
function Base.show(io::IO, sdata::SpatialData)
  N = ncoords(sdata)
  T = coordtype(sdata)
  n = nelms(sdata)
  print(io, "$n SpatialData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", sdata::SpatialData)
  println(io, domain(sdata))
  println(io, "  variables")
  varlines = ["    └─$(name(var)) ($(mactype(var)))" for var in variables(sdata)]
  print(io, join(sort(varlines), "\n"))
end
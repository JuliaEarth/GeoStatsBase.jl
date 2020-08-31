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
    @assert ne == nr "number of table rows ≠ number of mesh elements"
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
Tables.materializer(sdata::SpatialData) = Tables.materializer(values(sdata))
Tables.columnaccess(sdata::SpatialData) = Tables.columnaccess(values(sdata))
Tables.rowaccess(sdata::SpatialData) = Tables.rowaccess(values(sdata))
Tables.schema(sdata::SpatialData) = Tables.schema(values(sdata))
Tables.columns(sdata::SpatialData) = Tables.columns(values(sdata))
Tables.columnnames(sdata::SpatialData) = Tables.columnnames(values(sdata))
Tables.getcolumn(sdata::SpatialData, c::Symbol) = Tables.getcolumn(values(sdata), c)
Tables.rows(sdata::SpatialData) = Tables.rows(values(sdata))

# -------------
# VARIABLE API
# -------------

function variables(sdata::SpatialData)
  s = Tables.schema(sdata)
  ns, ts = s.names, s.types
  @. Variable(ns, nonmissing(ts))
end

Base.getindex(sdata::SpatialData, var::Symbol) =
  Tables.getcolumn(sdata, var)
Base.setindex!(sdata::SpatialData, vals, var::Symbol) =
  setindex!(values(sdata), vals, :, var)

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
  𝒟 = domain(sdata)
  𝒯 = values(sdata)
  s = Tables.schema(𝒯)
  vars = zip(s.names, s.types)
  println(io, 𝒟)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in vars]
  print(io, join(sort(varlines), "\n"))
end
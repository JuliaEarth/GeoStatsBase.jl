# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# helper function for table view
function viewtable(table, rows, cols)
  t = Tables.columns(table)
  v = map(cols) do c
    col = Tables.getcolumn(t, c)
    c => view(col, rows)
  end
  (; v...)
end

"""
    AbstractData

An abstract type to aid with custom spatial data types. Users can
subtype their domains from this type, and implement the methods in
`geotraits/data.jl`.
"""
abstract type AbstractData end

"""
    sdata₁ == sdata₂

Tells whether or not the spatial `sdata₁` and `sdata₂` are equal.
"""
==(sdata₁::AbstractData, sdata₂::AbstractData) =
  domain(sdata₁) == domain(sdata₂) &&
  values(sdata₁) == values(sdata₂)

# -----------
# TABLES API
# -----------

Tables.istable(::Type{<:AbstractData}) = true
Tables.materializer(sdata::AbstractData) = Tables.materializer(values(sdata))
Tables.columnaccess(sdata::AbstractData) = Tables.columnaccess(values(sdata))
Tables.rowaccess(sdata::AbstractData) = Tables.rowaccess(values(sdata))
Tables.schema(sdata::AbstractData) = Tables.schema(values(sdata))
Tables.columns(sdata::AbstractData) = Tables.columns(values(sdata))
Tables.columnnames(sdata::AbstractData) = Tables.columnnames(values(sdata))
Tables.getcolumn(sdata::AbstractData, c::Symbol) = Tables.getcolumn(values(sdata), c)
Tables.rows(sdata::AbstractData) = Tables.rows(values(sdata))

# -------------
# VARIABLE API
# -------------

function variables(sdata::AbstractData)
  s = Tables.schema(sdata)
  ns, ts = s.names, s.types
  @. Variable(ns, nonmissing(ts))
end

Base.getindex(sdata::AbstractData, var::Symbol) =
  Tables.getcolumn(sdata, var)

# ---------
# VIEW API
# ---------

Base.view(sdata::AbstractData, inds::AbstractVector{Int}) =
  DataView(sdata, inds, collect(name.(variables(sdata))))
Base.view(sdata::AbstractData, vars::AbstractVector{Symbol}) =
  DataView(sdata, 1:nelms(sdata), vars)
Base.view(sdata::AbstractData, inds, vars) =
  DataView(sdata, inds, vars)

# ------------
# IO methods
# ------------
function Base.show(io::IO, sdata::AbstractData)
  N = ncoords(sdata)
  T = coordtype(sdata)
  n = nelms(sdata)
  print(io, "$n SpatialData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", sdata::AbstractData)
  𝒟 = domain(sdata)
  𝒯 = values(sdata)
  s = Tables.schema(𝒯)
  vars = zip(s.names, s.types)
  println(io, 𝒟)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in vars]
  print(io, join(sort(varlines), "\n"))
end

function Base.show(io::IO, ::MIME"text/html", sdata::AbstractData)
  𝒟 = domain(sdata)
  𝒯 = values(sdata)
  s = Tables.schema(𝒯)
  vars = zip(s.names, s.types)
  println(io, 𝒟)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in vars]
  print(io, join(sort(varlines), "\n"))
end

#------------------
# IMPLEMENTATIONS
#------------------
"""
    SpatialData(domain, data)

Tabular `data` georeferenced in a spatial `domain`.
"""
struct SpatialData{𝒟,𝒯} <: AbstractData
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

domain(sdata::SpatialData) = sdata.domain
values(sdata::SpatialData) = sdata.table

"""
    DataView(sdata, inds, vars)

Return a view of spatial data `sdata` at `inds` and `vars`.
"""
struct DataView{𝒮,I,V} <: AbstractData
  data::𝒮
  inds::I
  vars::V
end

domain(dv::DataView) = view(domain(dv.data), dv.inds)
values(dv::DataView) = viewtable(values(dv.data), dv.inds, dv.vars)

# specialization for performance purposes
coordinates!(buff::AbstractVector, dv::DataView, ind::Int) =
  coordinates!(buff, dv.data, dv.inds[ind])

# specialization for correct nested views
Base.view(dv::DataView, inds::AbstractVector{Int}) =
  DataView(dv.data, dv.inds[inds], dv.vars)
Base.view(dv::DataView, vars::AbstractVector{Symbol}) =
  DataView(dv.data, dv.inds, vars)
Base.view(dv::DataView, inds, vars) =
  DataView(dv.data, dv.inds[inds], vars)

"""
    collect(dataview)

Materialize spatial `dataview` into a new block of memory.
"""
Base.collect(dv::DataView) = georef(values(dv), coordinates(dv))

function Base.show(io::IO, dv::DataView)
  N = ncoords(dv)
  T = coordtype(dv)
  n = nelms(dv)
  print(io, "$n DataView{$T,$N}")
end

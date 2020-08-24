# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialDataView(sdata, inds, vars)

Return a view of spatial data `sdata` at `inds` and `vars`.
"""
struct SpatialDataView
  data
  inds
  vars
end

geotrait(::SpatialDataView) = GeoData()
domain(dv::SpatialDataView) = view(domain(dv.data), dv.inds)
values(dv::SpatialDataView) = getindex(values(dv.data), dv.inds, dv.vars)

Base.collect(dv::SpatialDataView) = georef(values(dv), coordinates(dv))

# -----------------------------------
# specialize methods for performance
# -----------------------------------
nelms(dv::SpatialDataView) = length(dv.inds)

coordinates!(buff::AbstractVector, dv::SpatialDataView, ind::Int) =
  coordinates!(buff, dv.data, dv.inds[ind])

# -----------
# TABLES API
# -----------

Tables.istable(::Type{<:SpatialDataView}) = true
Tables.schema(dv::SpatialDataView) = Tables.schema(getindex(dv.data, dv.inds, dv.vars))
Tables.rowaccess(dv::SpatialDataView) = Tables.rowaccess(dv.data)
Tables.columnaccess(dv::SpatialDataView) = Tables.columnaccess(dv.data)
Tables.rows(dv::SpatialDataView) = Tables.rows(getindex(dv.data, dv.inds, dv.vars))
Tables.columns(dv::SpatialDataView) = Tables.columns(getindex(dv.data, dv.inds, dv.vars))
Tables.columnnames(dv::SpatialDataView) = Tables.columnnames(getindex(dv.data, dv.inds, dv.vars))
Tables.getcolumn(dv::SpatialDataView, c::Symbol) = Tables.getcolumn(getindex(dv.data, dv.inds, dv.vars), c)

# --------------
# DATAFRAME API
# --------------

Base.getindex(dv::SpatialDataView, inds, vars) =
  getindex(dv.data, dv.inds[inds], vars)
Base.setindex!(dv::SpatialDataView, vals, inds, vars) =
  setindex!(dv.data, vals, dv.inds[inds], vars)

# -------------
# VARIABLE API
# -------------

variables(dv::SpatialDataView) = variables(getindex(dv.data, dv.inds, dv.vars))

Base.getindex(dv::SpatialDataView, var::Symbol) =
  getindex(dv.data, dv.inds, var)
Base.setindex!(dv::SpatialDataView, vals, var::Symbol) =
  setindex!(dv.data, vals, dv.inds, var)

# -------------
# ITERATOR API
# -------------

Base.iterate(dv::SpatialDataView, state=1) =
  state > nelms(dv) ? nothing : (dv[state], state + 1)
Base.length(dv::SpatialDataView) = nelms(dv)
Base.eltype(dv::SpatialDataView) = typeof(dv[1])

# --------------
# INDEXABLE API
# --------------

Base.getindex(dv::SpatialDataView, ind::Int) =
  getindex(dv.data, dv.inds[ind], dv.vars)
Base.firstindex(dv::SpatialDataView) = 1
Base.lastindex(dv::SpatialDataView)  = nelms(dv)

# ---------
# VIEW API
# ---------

Base.view(dv::SpatialDataView, inds::AbstractVector{Int}) =
  SpatialDataView(dv.data, dv.inds[inds], dv.vars)
Base.view(dv::SpatialDataView, vars::AbstractVector{Symbol}) =
  SpatialDataView(dv.data, dv.inds, vars)
Base.view(dv::SpatialDataView, inds, vars) =
  SpatialDataView(dv.data, dv.inds[inds], vars)

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::SpatialDataView)
  N = ncoords(dv)
  T = coordtype(dv)
  n = nelms(dv)
  print(io, "$n SpatialDataView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::SpatialDataView)
  𝒟 = domain(dv)
  𝒯 = values(dv)
  s = Tables.schema(𝒯)
  vars = zip(s.names, s.types)
  println(io, 𝒟)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in vars]
  print(io, join(sort(varlines), "\n"))
end
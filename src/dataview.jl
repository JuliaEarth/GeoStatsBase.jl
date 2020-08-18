# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DataView(sdata, inds, vars)

Return a view of spatial data `sdata` at `inds` and `vars`.
"""
struct DataView{T,N} <: AbstractData{T,N}
  data
  inds
  vars
end

DataView(data, inds, vars) =
  DataView{coordtype(data),ndims(data)}(data, inds, vars)

domain(dv::DataView) = view(domain(dv.data), dv.inds)

npoints(dv::DataView) = length(dv.inds)

coordinates!(buff::AbstractVector, dv::DataView, ind::Int) =
  coordinates!(buff, dv.data, dv.inds[ind])

variables(dv::DataView) = variables(getindex(dv.data, dv.inds, dv.vars))

Base.values(dv::DataView) = getindex(values(dv.data), dv.inds, dv.vars)

Base.collect(dv::DataView) = georef(values(dv), coordinates(dv))

# -----------
# TABLES API
# -----------

Tables.schema(dv::DataView) = Tables.schema(getindex(dv.data, dv.inds, dv.vars))
Tables.rowaccess(dv::DataView) = Tables.rowaccess(dv.data)
Tables.columnaccess(dv::DataView) = Tables.columnaccess(dv.data)
Tables.rows(dv::DataView) = Tables.rows(getindex(dv.data, dv.inds, dv.vars))
Tables.columns(dv::DataView) = Tables.columns(getindex(dv.data, dv.inds, dv.vars))
Tables.columnnames(dv::DataView) = Tables.columnnames(getindex(dv.data, dv.inds, dv.vars))
Tables.getcolumn(dv::DataView, c::Symbol) = Tables.getcolumn(getindex(dv.data, dv.inds, dv.vars), c)

# --------------
# DATAFRAME API
# --------------

Base.getindex(dv::DataView, inds, vars) =
  getindex(dv.data, dv.inds[inds], vars)

Base.setindex!(dv::DataView, vals, inds, vars) =
  setindex!(dv.data, vals, dv.inds[inds], vars)

# -------------
# VARIABLE API
# -------------

Base.getindex(dv::DataView, var::Symbol) =
  getindex(dv.data, dv.inds, var)

Base.setindex!(dv::DataView, vals, var::Symbol) =
  setindex!(dv.data, vals, dv.inds, var)

# --------------
# INDEXABLE API
# --------------

Base.getindex(dv::DataView, ind::Int) =
  getindex(dv.data, dv.inds[ind], dv.vars)

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::DataView)
  N = ndims(dv)
  T = coordtype(dv)
  npts = npoints(dv)
  print(io, "$npts DataView{$T,$N}")
end
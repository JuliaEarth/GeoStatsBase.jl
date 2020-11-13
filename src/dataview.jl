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

Base.collect(dv::DataView) = georef(values(dv), coordinates(dv))

# -----------------------------------
# specialize methods for performance
# -----------------------------------
coordinates!(buff::AbstractVector, dv::DataView, ind::Int) =
  coordinates!(buff, dv.data, dv.inds[ind])

# ---------
# VIEW API
# ---------

Base.view(dv::DataView, inds::AbstractVector{Int}) =
  DataView(dv.data, dv.inds[inds], dv.vars)
Base.view(dv::DataView, vars::AbstractVector{Symbol}) =
  DataView(dv.data, dv.inds, vars)
Base.view(dv::DataView, inds, vars) =
  DataView(dv.data, dv.inds[inds], vars)

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::DataView)
  N = ncoords(dv)
  T = coordtype(dv)
  n = nelms(dv)
  print(io, "$n DataView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::DataView)
  𝒟 = domain(dv)
  𝒯 = values(dv)
  s = Tables.schema(𝒯)
  vars = zip(s.names, s.types)
  println(io, 𝒟)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in vars]
  print(io, join(sort(varlines), "\n"))
end
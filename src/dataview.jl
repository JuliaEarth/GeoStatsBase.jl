# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DataView(spatialdata, inds, vars)

Return a view of `spatialdata` at `inds` and `vars`.

### Notes

This type implements the `AbstractData` interface.
"""
struct DataView{T,N,
                S<:AbstractData{T,N},
                I<:AbstractVector{Int},
                V<:AbstractVector{Symbol}} <: AbstractData{T,N}
  data::S
  inds::I
  vars::V
end

domain(dv::DataView) = view(domain(dv.data), dv.inds)

npoints(dv::DataView) = length(dv.inds)

coordinates!(buff::AbstractVector, dv::DataView, ind::Int) =
  coordinates!(buff, dv.data, dv.inds[ind])

function variables(dv::DataView)
  nt = (; [(var,V) for (var,V) in variables(dv.data) if var ∈ dv.vars]...)
  Variables{typeof(nt)}(nt)
end

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

Base.getindex(dv::DataView, inds::AbstractVector{Int}) =
  getindex(dv.data, dv.inds[inds], dv.vars)

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::DataView)
  N = ndims(dv)
  T = coordtype(dv)
  npts = npoints(dv)
  print(io, "$npts DataView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::DataView)
  println(io, dv)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(dv)]
  print(io, join(varlines, "\n"))
end

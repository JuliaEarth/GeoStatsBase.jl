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
  vars = [(var,V) for (var,V) in variables(dv.data) if var ∈ dv.vars]
  ns, ts = first.(vars), last.(vars)
  nt = NamedTuple{Tuple(ns)}(ts)
  Variables{typeof(nt)}(nt)
end

Base.getindex(dv::DataView, ind::Int, var::Symbol) =
  getindex(dv.data, dv.inds[ind], var)

Base.setindex!(dv::DataView, val, ind::Int, var::Symbol) =
  setindex!(dv.data, val, dv.inds[ind], var)

function Base.setindex!(dv::DataView, vals::AbstractArray, var::Symbol)
  for (ind, val) in enumerate(vals)
    setindex!(dv.data, val, dv.inds[ind], var)
  end
end

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

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
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

variables(dv::DataView) =
  Dict(var => V for (var,V) in variables(dv.data) if var ∈ dv.vars)

Base.getindex(dv::DataView, ind::Int, var::Symbol) =
  getindex(dv.data, dv.inds[ind], var)

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

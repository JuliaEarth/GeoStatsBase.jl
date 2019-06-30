# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SpatialDataView(spatialdata, inds)

Return a view of `spatialdata` at `inds`.

### Notes

This type implements the `AbstractData` interface.
"""
struct SpatialDataView{T,N,
                       S<:AbstractData{T,N},
                       I<:AbstractVector{Int}} <: AbstractData{T,N}
  data::S
  inds::I
end

domain(dv::SpatialDataView) = view(domain(dv.data), dv.inds)

variables(view::SpatialDataView) = variables(view.data)

value(view::SpatialDataView, ind::Int, var::Symbol) =
  value(view.data, view.inds[ind], var)

# ------------
# IO methods
# ------------
function Base.show(io::IO, view::SpatialDataView{T,N,S,I}) where {T,N,
                                                                  S<:AbstractData{T,N},
                                                                  I<:AbstractVector{Int}}
  npts = npoints(view)
  print(io, "$npts SpatialDataView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", view::SpatialDataView)
  println(io, view)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(view)]
  print(io, join(varlines, "\n"))
end

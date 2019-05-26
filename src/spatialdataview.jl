# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SpatialDataView(spatialdata, inds)

Return a view of `spatialdata` at `inds`.

### Notes

This type implements the `AbstractSpatialData` interface.
"""
struct SpatialDataView{T<:Real,N,
                       S<:AbstractSpatialData{T,N},
                       I<:AbstractVector{Int}} <: AbstractSpatialData{T,N}
  data::S
  inds::I
end

valuetype(view::SpatialDataView, var::Symbol) = valuetype(view.data, var)

coordnames(view::SpatialDataView) = coordnames(view.data)

variables(view::SpatialDataView) = variables(view.data)

npoints(view::SpatialDataView) = length(view.inds)

coordinates!(buff::AbstractVector, view::SpatialDataView, ind::Int) =
  coordinates!(buff, view.data, view.inds[ind])

value(view::SpatialDataView, ind::Int, var::Symbol) =
  value(view.data, view.inds[ind], var)

Base.isvalid(view::SpatialDataView, ind::Int, var::Symbol) =
  isvalid(view.data, view.inds[ind], var)

# ------------
# IO methods
# ------------
function Base.show(io::IO, view::SpatialDataView{T,N,S,I}) where {T<:Real,N,
                                                                  S<:AbstractSpatialData{T,N},
                                                                  I<:AbstractVector{Int}}
  npts = npoints(view)
  print(io, "$npts SpatialDataView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", view::SpatialDataView)
  println(io, view)
  println(io, "  variables")
  varlines = ["    └─$var ($(eltype(array)))" for (var,array) in view.data.data]
  print(io, join(varlines, "\n"))
end

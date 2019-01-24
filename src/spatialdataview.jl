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

Base.ndims(view::SpatialDataView) = ndims(view.data)

coordtype(view::SpatialDataView) = coordtype(view.data)

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

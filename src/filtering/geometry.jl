# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeometryFilter(geometry)

A filter method to retain locations in spatial objects
that are inside a given `geometry`.
"""
struct GeometryFilter{G} <: AbstractFilter
  geometry::G
end

Base.filter(object, filt::GeometryFilter) =
  _filter(object, filt.geometry)

_filter(object, geometry::AbstractGeometry) =
  collect(view(object, _inside(object, geometry)))

function _inside(object, r::Rectangle)
  N = ndims(object)
  T = coordtype(object)

  x = MVector{N,T}(undef)

  inds = Vector{Int}()
  for i in 1:npoints(object)
    coordinates!(x, object, i)
    x ∈ r && push!(inds, i)
  end

  inds
end
# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RectangleCoverer

A method for covering spatial objects with a minimum axis-aligned
bounding rectangle (or bounding box).
"""
struct RectangleCoverer <: AbstractCoverer end

function cover(domain::AbstractDomain{T,N}, coverer::RectangleCoverer) where {N,T}
  lowerleft  = MVector(ntuple(i->typemax(T), N))
  upperright = MVector(ntuple(i->typemin(T), N))

  x = MVector{N,T}(undef)
  for l in 1:npoints(domain)
    coordinates!(x, domain, l)
    for d in 1:N
      x[d] < lowerleft[d]  && (lowerleft[d]  = x[d])
      x[d] > upperright[d] && (upperright[d] = x[d])
    end
  end

  Rectangle(Tuple(lowerleft), Tuple(upperright))
end

function cover(grid::RegularGrid, coverer::RectangleCoverer)
  lowerleft  = origin(grid)
  upperright = origin(grid) .+ (size(grid) .- 1) .* spacing(grid)

  Rectangle(lowerleft, upperright)
end

"""
    boundbox(object)

Return the minimum axis-aligned bounding rectangle of the spatial `object`.

### Notes

Equivalent to `cover(object, RectangleCoverer())`
"""
boundbox(object::AbstractSpatialObject) = cover(object, RectangleCoverer())

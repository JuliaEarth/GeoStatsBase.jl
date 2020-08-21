# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RectangleCoverer

A method for covering spatial objects with a minimum axis-aligned
bounding rectangle (or bounding box).
"""
struct RectangleCoverer <: AbstractCoverer end

function cover(domain, coverer::RectangleCoverer)
  N = ndims(domain)
  T = coordtype(domain)

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

  Rectangle(lowerleft, upperright)
end

cover(grid::RegularGrid, coverer::RectangleCoverer) =
  Rectangle(origin(grid), origin(grid) + (size(grid) .- 1) .* spacing(grid))

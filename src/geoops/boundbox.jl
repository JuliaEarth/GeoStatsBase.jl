# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    boundbox(object)

Return the minimum axis-aligned bounding rectangle of the spatial `object`.
"""
boundbox(obj) = boundbox(domain(obj))

function boundbox(obj::AbstractDomain)
  N = ncoords(obj)
  T = coordtype(obj)

  lowerleft  = MVector(ntuple(i->typemax(T), N))
  upperright = MVector(ntuple(i->typemin(T), N))

  x = MVector{N,T}(undef)
  for l in 1:nelms(obj)
    coordinates!(x, obj, l)
    for d in 1:N
      x[d] < lowerleft[d]  && (lowerleft[d]  = x[d])
      x[d] > upperright[d] && (upperright[d] = x[d])
    end
  end

  Rectangle(lowerleft, upperright)
end

function boundbox(obj::RegularGrid)
  lowerleft  = origin(obj)
  upperright = origin(obj) + (size(obj) .- 1) .* spacing(obj)
  Rectangle(lowerleft, upperright)
end
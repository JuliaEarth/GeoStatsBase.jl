# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    boundbox(object)

Return the minimum axis-aligned bounding rectangle of the spatial `object`.
"""
boundbox(obj) = boundbox(geotrait(obj), obj)

boundbox(::GeoData, obj) = boundbox(domain(obj))

function boundbox(::GeoDomain, object)
  N = ncoords(object)
  T = coordtype(object)

  lowerleft  = MVector(ntuple(i->typemax(T), N))
  upperright = MVector(ntuple(i->typemin(T), N))

  x = MVector{N,T}(undef)
  for l in 1:nelms(object)
    coordinates!(x, object, l)
    for d in 1:N
      x[d] < lowerleft[d]  && (lowerleft[d]  = x[d])
      x[d] > upperright[d] && (upperright[d] = x[d])
    end
  end

  Rectangle(lowerleft, upperright)
end

function boundbox(::GeoDomain, obj::RegularGrid)
  lowerleft  = origin(obj)
  upperright = origin(obj) + (size(obj) .- 1) .* spacing(obj)
  Rectangle(lowerleft, upperright)
end
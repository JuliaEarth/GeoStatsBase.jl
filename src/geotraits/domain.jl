# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    nelms(object)

Return the number of elements in `object`.
"""
nelms(obj) = nelms(geotrait(obj), obj)

"""
    ncoords(object)

Return the number of dimensions
(or coordinates) of the `object`.
"""
ncoords(obj) = ncoords(geotrait(obj), obj)

"""
    coordtype(object)

Return the coordinate type of the `object`.
"""
coordtype(obj) = coordtype(geotrait(obj), obj)

"""
    coordinates!(buff, object, ind)

Compute the coordinates of the `ind`-th
element of the `object` in `buff`.
"""
coordinates!(buff::AbstractVector, obj, ind::Int) =
  coordinates!(geotrait(obj), buff, obj, ind)
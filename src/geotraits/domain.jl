# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    npoints(object)

Return the number of points in `object`.
"""
npoints(obj) = npoints(geotrait(obj), obj)

"""
    ncoords(object)

Return the number of dimensions of `object`.
"""
ncoords(obj) = ncoords(geotrait(obj), obj)

"""
    coordtype(object)

Return the coordinate type of `object`.
"""
coordtype(obj) = coordtype(geotrait(obj), obj)

"""
    coordinates!(buff, object, ind)

Non-allocating version of [`coordinates`](@ref).
"""
coordinates!(buff::AbstractVector, obj, ind::Int) =
  coordinates!(geotrait(obj), buff, obj, ind)
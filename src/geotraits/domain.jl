# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    nelms(object)

Return the number of elements in `object`.
"""
function nelms end

"""
    ncoords(object)

Return the number of dimensions
(or coordinates) of the `object`.
"""
function ncoords end

"""
    coordtype(object)

Return the coordinate type of the `object`.
"""
function coordtype end

"""
    coordinates!(buff, object, ind)

Compute the coordinates of the `ind`-th
element of the `object` in `buff`.
"""
function coordinates! end
# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    boundbox(object)

Return the minimum axis-aligned bounding rectangle of the spatial `object`.
"""
boundbox(object) = cover(object, RectangleCoverer())
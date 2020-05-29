# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LinearPath

Traverse a spatial object with `N` points in order `1:N`.
"""
struct LinearPath <: AbstractPath end

traverse(object, path::LinearPath) = 1:npoints(object)

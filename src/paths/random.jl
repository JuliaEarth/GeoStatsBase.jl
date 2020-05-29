# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RandomPath

Traverse a spatial object with `N` points in a random
permutation of `1:N`.
"""
struct RandomPath <: AbstractPath end

traverse(object, path::RandomPath) = randperm(npoints(object))

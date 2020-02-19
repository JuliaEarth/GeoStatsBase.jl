# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialPredicatePartitioner(pred)

A method for partitioning spatial objects with a given spatial
predicate function `pred(x, y)`.
"""
struct SpatialPredicatePartitioner <: AbstractSpatialPredicatePartitioner
  pred::Function
end

(p::SpatialPredicatePartitioner)(x, y) = p.pred(x, y)

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SPredicatePartition(pred)

A method for partitioning spatial objects with a given spatial
predicate function `pred(x, y)`.
"""
struct SPredicatePartition <: SPredicatePartitionMethod
  pred::Function
end

(p::SPredicatePartition)(x, y) = p.pred(x, y)

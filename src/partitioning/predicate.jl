# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PredicatePartition(pred)

A method for partitioning spatial objects with a given predicate
function `pred(i, j)`.
"""
struct PredicatePartition <: PredicatePartitionMethod
  pred::Function
end

(p::PredicatePartition)(i, j) = p.pred(i, j)

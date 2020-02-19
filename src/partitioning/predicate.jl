# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PredicatePartitioner(pred)

A method for partitioning spatial objects with a given predicate
function `pred(i, j)`.
"""
struct PredicatePartitioner <: AbstractPredicatePartitioner
  pred::Function
end

(p::PredicatePartitioner)(i, j) = p.pred(i, j)

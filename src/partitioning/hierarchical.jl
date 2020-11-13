# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    HierarchicalPartitioner(first, second)

A partitioning method in which a `first` partition is applied
and then a `second` partition is applied to each subset of the
`first`.
"""
struct HierarchicalPartitioner <: AbstractPartitioner
  first::AbstractPartitioner
  second::AbstractPartitioner
end

function partition(object, partitioner::HierarchicalPartitioner)
  result = Vector{Vector{Int}}()

  # use first partition method
  p = partition(object, partitioner.first)

  # use second method to partition the first
  s = subsets(p)
  for (i, d) in Iterators.enumerate(p)
    q = partition(d, partitioner.second)

    for js in subsets(q)
      push!(result, s[i][js])
    end
  end

  SpatialPartition(object, result)
end

→(first, second) = HierarchicalPartitioner(first, second)

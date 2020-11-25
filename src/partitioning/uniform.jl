# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniformPartition(k, [shuffle])

A method for partitioning spatial data uniformly into `k` subsets
of approximately equal size. Optionally `shuffle` the data (default
to true).
"""
struct UniformPartition <: PartitionMethod
  k::Int
  shuffle::Bool
end

UniformPartition(k::Int) = UniformPartition(k, true)

function partition(object, partitioner::UniformPartition)
  n = nelms(object)
  k = partitioner.k

  @assert k ≤ n "number of subsets must be smaller than number of points"

  inds = partitioner.shuffle ? shuffle(1:n) : collect(1:n)
  subsets = collect(Iterators.partition(inds, n ÷ k))

  SpatialPartition(object, subsets)
end

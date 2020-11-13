# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniformPartitioner(k, [shuffle])

A method for partitioning spatial data uniformly into `k` subsets
of approximately equal size. Optionally `shuffle` the data (default
to true).
"""
struct UniformPartitioner <: AbstractPartitioner
  k::Int
  shuffle::Bool
end

UniformPartitioner(k::Int) = UniformPartitioner(k, true)

function partition(object, partitioner::UniformPartitioner)
  n = nelms(object)
  k = partitioner.k

  @assert k ≤ n "number of subsets must be smaller than number of points"

  inds = partitioner.shuffle ? shuffle(1:n) : collect(1:n)
  subsets = collect(Iterators.partition(inds, n ÷ k))

  SpatialPartition(object, subsets)
end

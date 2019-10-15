# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
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

function partition(object::AbstractSpatialObject{T,N},
                   partitioner::UniformPartitioner) where {N,T}
  npts = npoints(object)
  nset = partitioner.k

  @assert nset ≤ npts "number of subsets must be smaller than number of points"

  inds = partitioner.shuffle ? shuffle(1:npts) : collect(1:npts)
  subsets = collect(Iterators.partition(inds, npts ÷ nset))

  SpatialPartition(object, subsets)
end

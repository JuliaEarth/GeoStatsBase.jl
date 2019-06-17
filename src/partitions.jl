# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SpatialPartition

A partition of spatial data.
"""
struct SpatialPartition{O<:AbstractSpatialObject}
  object::O
  subsets::Vector{Vector{Int}}
end

SpatialPartition(object, subsets) =
  SpatialPartition{typeof(object)}(object, subsets)

"""
    subsets(partition)

Return the subsets of indices in spatial object
that make up the `partition`.
"""
subsets(partition::SpatialPartition) = partition.subsets

"""
    Base.iterate(partition)

Iterate the partition returning views of spatial object.
"""
function Base.iterate(partition::SpatialPartition, state=1)
  if state > length(partition.subsets)
    nothing
  else
    view(partition.object, partition.subsets[state]), state + 1
  end
end

"""
    Base.length(partition)

Return the number of subsets in `partition`.
"""
Base.length(partition::SpatialPartition) = length(partition.subsets)

"""
    AbstractPartitioner

A method for partitioning spatial objects.
"""
abstract type AbstractPartitioner end

"""
    AbstractFunctionPartitioner

A method for partitioning spatial objects with partition functions.
"""
abstract type AbstractFunctionPartitioner <: AbstractPartitioner end

"""
    AbstractSpatialFunctionPartitioner

A method for partitioning spatial objects with spatial partition functions.
"""
abstract type AbstractSpatialFunctionPartitioner <: AbstractFunctionPartitioner end

"""
    partition(object, partitioner)

Partition `object` with partition method `partitioner`.
"""
partition(::AbstractSpatialObject, ::AbstractPartitioner) = error("not implemented")

function partition(object::AbstractSpatialObject{T,N},
                   partitioner::AbstractFunctionPartitioner) where {N,T}
  subsets = Vector{Vector{Int}}()
  for i in randperm(npoints(object))
    inserted = false
    for subset in subsets
      j = subset[1]
      if partitioner(i, j)
        push!(subset, i)
        inserted = true
        break
      end
    end

    if !inserted
      push!(subsets, [i])
    end
  end

  SpatialPartition(object, subsets)
end

function partition(object::AbstractSpatialObject{T,N},
                   partitioner::AbstractSpatialFunctionPartitioner) where {N,T}
  # pre-allocate memory for coordinates
  x = MVector{N,T}(undef)
  y = MVector{N,T}(undef)

  subsets = Vector{Vector{Int}}()
  for i in randperm(npoints(object))
    coordinates!(x, object, i)

    inserted = false
    for subset in subsets
      coordinates!(y, object, subset[1])

      if partitioner(x, y)
        push!(subset, i)
        inserted = true
        break
      end
    end

    if !inserted
      push!(subsets, [i])
    end
  end

  SpatialPartition(object, subsets)
end

#------------------
# IMPLEMENTATIONS
#------------------
include("partitions/uniform_partitioner.jl")
include("partitions/fraction_partitioner.jl")
include("partitions/block_partitioner.jl")
include("partitions/ball_partitioner.jl")
include("partitions/plane_partitioner.jl")
include("partitions/direction_partitioner.jl")
include("partitions/function_partitioner.jl")
include("partitions/product_partitioner.jl")
include("partitions/hierarchical_partitioner.jl")

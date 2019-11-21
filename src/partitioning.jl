# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialPartition(object, subsets, metadata=Dict())

A partition of a spatial `object` into `subsets`.
Optionally, save `metadata` in the partitioning
algorithm.
"""
struct SpatialPartition{O<:AbstractSpatialObject}
  object::O
  subsets::Vector{Vector{Int}}
  metadata::Dict
end

SpatialPartition(object, subsets, metadata=Dict()) =
  SpatialPartition{typeof(object)}(object, subsets, metadata)

"""
    subsets(partition)

Return the subsets of indices in spatial object
that make up the `partition`.
"""
subsets(partition::SpatialPartition) = partition.subsets

"""
    metadata(partition)

Return the metadata dictionary saved in the partition.
"""
metadata(partition::SpatialPartition) = partition.metadata

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
    Base.getindex(partition, ind)

Return `ind`-th object in the `partition` as a view.
"""
Base.getindex(partition::SpatialPartition, ind::Int) =
  view(partition.object, partition.subsets[ind])

"""
    Base.getindex(partition, inds)

Return the ind-th object in the `partition` for
each ind in `inds`.
"""
Base.getindex(partition::SpatialPartition, inds::AbstractVector{Int}) =
  [getindex(partition, ind) for ind in inds]

"""
    Base.getindex(partition, prop)

Return the metadata `prop` for each subset in the partition.
"""
Base.getindex(partition::SpatialPartition, prop::Symbol) =
  partition.metadata[prop]

# ------------
# IO methods
# ------------
function Base.show(io::IO, partition::SpatialPartition)
  nsubsets = length(partition.subsets)
  print(io, "$nsubsets SpatialPartition")
end

function Base.show(io::IO, ::MIME"text/plain", partition::SpatialPartition)
  meta = metadata(partition)
  println(io, partition)
  println(io, "  N° points")
  setlines = ["  └─$(length(subset))" for subset in partition.subsets]
  print(io, join(setlines, "\n"))
  if !isempty(meta)
    print(io, "\n  metadata: ", join(keys(meta), ", "))
  end
end

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
partition(::AbstractSpatialObject, ::AbstractPartitioner) = @error "not implemented"

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
include("partitioning/uniform.jl")
include("partitioning/fraction.jl")
include("partitioning/slic.jl")
include("partitioning/block.jl")
include("partitioning/bisect_point.jl")
include("partitioning/bisect_fraction.jl")
include("partitioning/ball.jl")
include("partitioning/plane.jl")
include("partitioning/direction.jl")
include("partitioning/function.jl")
include("partitioning/variable.jl")
include("partitioning/product.jl")
include("partitioning/hierarchical.jl")

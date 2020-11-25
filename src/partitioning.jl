# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialPartition(object, subsets, [metadata])

A partition of a spatial `object` into `subsets`.
Optionally, save `metadata` as a dictionary.
"""
struct SpatialPartition{O}
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

# --------------
# INDEXABLE API
# --------------

Base.iterate(partition::SpatialPartition, state=1) =
  state > length(partition) ? nothing : (partition[state], state + 1)

Base.length(partition::SpatialPartition) = length(partition.subsets)

Base.getindex(partition::SpatialPartition, ind::Int) =
  view(partition.object, partition.subsets[ind])

Base.getindex(partition::SpatialPartition, inds::AbstractVector{Int}) =
  [getindex(partition, ind) for ind in inds]

# ------------
# IO methods
# ------------
function Base.show(io::IO, partition::SpatialPartition)
  nsubsets = length(partition.subsets)
  print(io, "$nsubsets SpatialPartition")
end

function Base.show(io::IO, ::MIME"text/plain", partition::SpatialPartition)
  subs = partition.subsets
  meta = partition.metadata
  lines = ["  └─$(length(sub))" for sub in subs]
  lines = length(lines) > 11 ? [lines[1:5]; ["  ⋮"]; lines[end-4:end]] : lines
  println(io, partition)
  println(io, "  N° points")
  print(io, join(lines, "\n"))
  if !isempty(meta)
    print(io, "\n  metadata: ", join(keys(meta), ", "))
  end
end

"""
    PartitionMethod

A method for partitioning spatial objects.
"""
abstract type PartitionMethod end

"""
    partition(object, method)

Partition `object` with partition `method`.
"""
function partition end

"""
    PredicatePartitionMethod

A method for partitioning spatial objects with predicate functions.
"""
abstract type PredicatePartitionMethod <: PartitionMethod end

function partition(object, method::PredicatePartitionMethod)
  subsets = Vector{Vector{Int}}()
  for i in randperm(nelms(object))
    inserted = false
    for subset in subsets
      j = subset[1]
      if method(i, j)
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

"""
    SPredicatePartitionMethod

A method for partitioning spatial objects with spatial predicate functions.
"""
abstract type SPredicatePartitionMethod <: PartitionMethod end

function partition(object, method::SPredicatePartitionMethod)
  N = ncoords(object)
  T = coordtype(object)

  # pre-allocate memory for coordinates
  x = MVector{N,T}(undef)
  y = MVector{N,T}(undef)

  subsets = Vector{Vector{Int}}()
  for i in randperm(nelms(object))
    coordinates!(x, object, i)

    inserted = false
    for subset in subsets
      coordinates!(y, object, subset[1])

      if method(x, y)
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
include("partitioning/random.jl")
include("partitioning/fraction.jl")
include("partitioning/slic.jl")
include("partitioning/block.jl")
include("partitioning/bisect_point.jl")
include("partitioning/bisect_fraction.jl")
include("partitioning/ball.jl")
include("partitioning/plane.jl")
include("partitioning/direction.jl")
include("partitioning/predicate.jl")
include("partitioning/spatial_predicate.jl")
include("partitioning/variable.jl")
include("partitioning/product.jl")
include("partitioning/hierarchical.jl")

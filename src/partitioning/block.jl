# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    BlockPartitioner(side)

A method for partitioning spatial objects into blocks of given `side`.
"""
struct BlockPartitioner{T} <: AbstractPartitioner
  side::T
end

function partition(object::AbstractSpatialObject{T,N},
                   partitioner::BlockPartitioner) where {N,T}
  side = partitioner.side
  bbox = boundbox(object)

  @assert side ≤ minimum(sides(bbox)) "block side is too large"

  # bounding box properties
  ce = center(bbox)
  lo = lowerleft(bbox)
  up = upperright(bbox)

  # find number of blocks to left and right
  nleft  = @. ceil(Int, (ce - lo) / side)
  nright = @. ceil(Int, (up - ce) / side)

  origin  = @. ce - nleft * side
  nblocks = @. nleft + nright

  subsets = [Vector{Int}() for i in 1:prod(nblocks)]
  neighbors = [Vector{Int}() for i in 1:prod(nblocks)]

  # Cartesian to linear indices
  linear = LinearIndices(Dims(nblocks))

  coords = MVector{N,T}(undef)
  for j in 1:npoints(object)
    coordinates!(coords, object, j)

    # find block coordinates
    c = @. floor(Int, (coords - origin) / side) + 1
    @inbounds for i in 1:N
      c[i] = clamp(c[i], 1, nblocks[i])
    end
    bcoords = CartesianIndex(Tuple(c))

    # block index
    i = linear[bcoords]

    append!(subsets[i], j)
  end

  # neighboring blocks metadata
  bstart  = CartesianIndex(ntuple(i -> 1, N))
  boffset = CartesianIndex(ntuple(i -> 1, N))
  bfinish = CartesianIndex(Dims(nblocks))
  for (i, bcoords) in enumerate(bstart:bfinish)
    for b in (bcoords - boffset):(bcoords + boffset)
      if all(Tuple(bstart) .≤ Tuple(b) .≤ Tuple(bfinish)) && b ≠ bcoords
        push!(neighbors[i], linear[b])
      end
    end
  end

  # filter out empty blocks
  empty = isempty.(subsets)
  subsets = subsets[.!empty]
  neighbors = neighbors[.!empty]
  for i in findall(empty)
    for n in neighbors
      setdiff!(n, i)
    end
  end

  # save metadata
  metadata = Dict(:neighbors => neighbors)

  SpatialPartition(object, subsets, metadata)
end

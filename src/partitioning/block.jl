# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockPartitioner(sides)
    BlockPartitioner(side₁, side₂, ...)

A method for partitioning spatial objects into blocks of given `sides`.
"""
struct BlockPartitioner{T,N} <: AbstractPartitioner
  sides::SVector{N,T}
end

BlockPartitioner(sides::NTuple{N,T}) where {N,T} =
  BlockPartitioner{T,N}(sides)

BlockPartitioner(sides::Vararg{T,N}) where {N,T} =
  BlockPartitioner(sides)

function partition(object, partitioner::BlockPartitioner)
  N = ndims(object)
  T = coordtype(object)

  psides = partitioner.sides
  bbox = boundbox(object)

  @assert all(psides .≤ sides(bbox)) "invalid block sides"

  # bounding box properties
  lo, up = extrema(bbox)
  ce = center(bbox)

  # find number of blocks to left and right
  nleft  = @. ceil(Int, (ce - lo) / psides)
  nright = @. ceil(Int, (up - ce) / psides)

  start   = @. ce - nleft * psides
  nblocks = @. nleft + nright

  subsets   = [Vector{Int}() for i in 1:prod(nblocks)]
  neighbors = [Vector{Int}() for i in 1:prod(nblocks)]

  # Cartesian to linear indices
  linear = LinearIndices(Dims(nblocks))

  coords = MVector{N,T}(undef)
  for j in 1:npoints(object)
    coordinates!(coords, object, j)

    # find block coordinates
    c = @. floor(Int, (coords - start) / psides) + 1
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

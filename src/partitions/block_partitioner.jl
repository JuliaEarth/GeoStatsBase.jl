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

  coords  = MVector{N,T}(undef)
  linear = LinearIndices(Dims(nblocks))
  for j in 1:npoints(object)
    coordinates!(coords, object, j)

    # find block coordinates
    c = @. floor(Int, (coords - origin) / side) + 1
    @inbounds for i in 1:N
      c[i] = clamp(c[i], 1, nblocks[i])
    end

    # block index
    i = linear[c...]

    append!(subsets[i], j)
  end

  filter!(!isempty, subsets)

  SpatialPartition(object, subsets)
end

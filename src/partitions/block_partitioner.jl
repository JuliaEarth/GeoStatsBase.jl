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

  objbounds  = bounds(object)
  lowerleft  = first.(objbounds)
  upperright = last.(objbounds)

  @assert minimum(upperright .- lowerleft) ≥ side "block side is too large"

  center = @. (lowerleft + upperright) / 2
  Δleft  = @. ceil(Int, (center  - lowerleft) / side)
  Δright = @. ceil(Int, (upperright - center) / side)

  origin  = @. center - Δleft*side
  nblocks = @. Δleft + Δright

  subsets = [Int[] for i in 1:prod(nblocks)]

  coords  = MVector{N,T}(undef)
  linear = LinearIndices(Dims(nblocks))
  for j in 1:npoints(object)
    coordinates!(coords, object, j)

    # find block coordinates
    c = floor.(Int, (Tuple(coords) .- origin) ./ side) .+ 1
    bcoords = ntuple(i->@inbounds(return clamp(c[i], 1, nblocks[i])), N)

    # block index
    i = linear[bcoords...]

    append!(subsets[i], j)
  end

  filter!(!isempty, subsets)

  SpatialPartition(object, subsets)
end

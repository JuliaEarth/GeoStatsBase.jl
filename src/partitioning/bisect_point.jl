# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BisectPointPartitioner(normal, point)

A method for partitioning spatial data into two half spaces
defined by a `normal` direction and a reference `point`.
"""
struct BisectPointPartitioner{T,N} <: AbstractPartitioner
  normal::SVector{N,T}
  point::SVector{N,T}
end

BisectPointPartitioner(normal::NTuple{N,T},
                  point::NTuple{N,T}=ntuple(i->zero(T), N)) where {T,N} =
  BisectPointPartitioner{T,N}(normalize(SVector(normal)), SVector(point))

function partition(object::AbstractSpatialObject{T,N},
                   partitioner::BisectPointPartitioner{T,N}) where {T,N}
  n = partitioner.normal
  p = partitioner.point

  x = MVector{N,T}(undef)

  left  = Vector{Int}()
  right = Vector{Int}()
  for location in 1:npoints(object)
    coordinates!(x, object, location)
    if (x - p) ⋅ n < zero(T)
      push!(left, location)
    else
      push!(right, location)
    end
  end

  SpatialPartition(object, [left,right])
end

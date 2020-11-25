# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BisectPointPartition(normal, point)

A method for partitioning spatial data into two half spaces
defined by a `normal` direction and a reference `point`.
"""
struct BisectPointPartition{T,N} <: PartitionMethod
  normal::SVector{N,T}
  point::SVector{N,T}

  function BisectPointPartition{T,N}(normal, point) where {N,T}
    new(normalize(normal), point)
  end
end

BisectPointPartition(normal::SVector{N,T}, point::SVector{N,T}) where {T,N} =
  BisectPointPartition{T,N}(normal, point)

BisectPointPartition(normal::NTuple{N,T}, point::NTuple{N,T}) where {T,N} =
 BisectPointPartition(SVector(normal), SVector(point))

function partition(object, method::BisectPointPartition)
  N = ncoords(object)
  T = coordtype(object)
  
  n = method.normal
  p = method.point

  x = MVector{N,T}(undef)

  left  = Vector{Int}()
  right = Vector{Int}()
  for location in 1:nelms(object)
    coordinates!(x, object, location)
    if (x - p) ⋅ n < zero(T)
      push!(left, location)
    else
      push!(right, location)
    end
  end

  SpatialPartition(object, [left,right])
end

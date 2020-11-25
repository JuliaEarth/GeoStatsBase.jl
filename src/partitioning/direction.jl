# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DirectionPartition(direction; tol=1e-6)

A method for partitioning spatial objects along a given `direction`
with bandwidth tolerance `tol`.
"""
struct DirectionPartition{T,N} <: SPredicatePartitionMethod
  direction::SVector{N,T}
  tol::Float64

  function DirectionPartition{T,N}(direction, tol) where {N,T}
    new(normalize(direction), tol)
  end
end

DirectionPartition(direction::SVector{N,T}; tol=1e-6) where {T,N} =
  DirectionPartition{T,N}(direction, tol)

DirectionPartition(direction::NTuple{N,T}; tol=1e-6) where {T,N} =
  DirectionPartition(SVector(direction), tol=tol)

(p::DirectionPartition)(x, y) = begin
  δ = x - y
  d = p.direction
  norm(δ - (δ⋅d)*d) < p.tol
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DirectionPartitioner(direction; tol=1e-6)

A method for partitioning spatial objects along a given `direction`
with bandwidth tolerance `tol`.
"""
struct DirectionPartitioner{T,N} <: AbstractSpatialPredicatePartitioner
  direction::SVector{N,T}
  tol::Float64

  function DirectionPartitioner{T,N}(direction, tol) where {N,T}
    new(normalize(direction), tol)
  end
end

DirectionPartitioner(direction::SVector{N,T}; tol=1e-6) where {T,N} =
  DirectionPartitioner{T,N}(direction, tol)

DirectionPartitioner(direction::NTuple{N,T}; tol=1e-6) where {T,N} =
  DirectionPartitioner(SVector(direction), tol=tol)

(p::DirectionPartitioner)(x, y) = begin
  δ = x - y
  d = p.direction
  norm(δ - (δ⋅d)*d) < p.tol
end

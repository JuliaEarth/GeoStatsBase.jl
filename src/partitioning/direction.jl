# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DirectionPartitioner(direction; tol=1e-6)

A method for partitioning spatial objects along a given `direction`
with bandwidth tolerance `tol`.
"""
struct DirectionPartitioner{T,N} <: AbstractSpatialFunctionPartitioner
  direction::SVector{N,T}
  tol::Float64
end

DirectionPartitioner(direction::NTuple{N,T}; tol=1e-6) where {T,N} =
  DirectionPartitioner{T,N}(normalize(SVector(direction)), tol)

(p::DirectionPartitioner)(x, y) = begin
  d = p.direction
  @. y = x - y
  norm(y .- (y ⋅ d) .* d) < p.tol
end

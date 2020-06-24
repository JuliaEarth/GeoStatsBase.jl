# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PlanePartitioner(normal; tol=1e-6)

A method for partitioning spatial data into a family of hyperplanes defined
by a `normal` direction. Two points `x` and `y` belong to the same
hyperplane when `(x - y) ⋅ normal < tol`.
"""
struct PlanePartitioner{T,N} <: AbstractSpatialPredicatePartitioner
  normal::SVector{N,T}
  tol::Float64

  function PlanePartitioner{T,N}(normal, tol) where {N,T}
    new(normalize(normal), tol)
  end
end

PlanePartitioner(normal::SVector{N,T}; tol=1e-6) where {T,N} =
  PlanePartitioner{T,N}(normal, tol)

PlanePartitioner(normal::NTuple{N,T},; tol=1e-6) where {T,N} =
  PlanePartitioner(SVector(normal), tol=tol)

(p::PlanePartitioner)(x, y) = abs((x - y) ⋅ p.normal) < p.tol

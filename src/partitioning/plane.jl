# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    PlanePartitioner(normal; tol=1e-6)

A method for partitioning spatial data into a family of hyperplanes defined
by a `normal` direction. Two points `x` and `y` belong to the same
hyperplane when `(x - y) ⋅ normal < tol`.
"""
struct PlanePartitioner{T,N} <: AbstractSpatialFunctionPartitioner
  normal::SVector{N,T}
  tol::Float64
end

PlanePartitioner(normal::NTuple{N,T}; tol=1e-6) where {T,N} =
  PlanePartitioner{T,N}(normalize(SVector(normal)), tol)

(p::PlanePartitioner)(x, y) = abs((x - y) ⋅ p.normal) < p.tol

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BisectFractionPartitioner(normal, fraction=0.5, maxiter=10)

A method for partitioning spatial data into two half spaces
defined by a `normal` direction and a `fraction` of points.
The partition is returned within `maxiter` bisection iterations.
"""
struct BisectFractionPartitioner{T,N} <: AbstractPartitioner
  normal::SVector{N,T}
  fraction::Float64
  maxiter::Int

  function BisectFractionPartitioner{T,N}(normal, fraction, maxiter) where {N,T}
    new(normalize(normal), fraction, maxiter)
  end
end

BisectFractionPartitioner(normal::SVector{N,T}, fraction=0.5, maxiter=10) where {T,N} =
  BisectFractionPartitioner{T,N}(normal, fraction, maxiter)

BisectFractionPartitioner(normal::NTuple{N,T}, fraction=0.5, maxiter=10) where {T,N} =
  BisectFractionPartitioner(SVector(normal), fraction, maxiter)

function partition(object, partitioner::BisectFractionPartitioner)
  bbox = boundbox(object)
  n = partitioner.normal
  f = partitioner.fraction
  c = center(bbox)
  d = diagonal(bbox)

  # maximum number of bisections
  maxiter = partitioner.maxiter

  iter = 0; p = 0
  a = c - d/2 * n
  b = c + d/2 * n
  while iter < maxiter
    m = (a + b) / 2

    p = partition(object, BisectPointPartitioner(n, m))
    g = nelms(p[1]) / nelms(object)

    g ≈ f && break
    g > f && (b = m)
    g < f && (a = m)

    iter += 1
  end

  p
end

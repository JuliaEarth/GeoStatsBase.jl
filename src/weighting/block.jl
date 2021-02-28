# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockWeighting(sides)
    BlockWeighting(side₁, side₂, ...)

A weighting method that assigns weights to points in spatial object
based on blocks of given `sides`. The number `n` of points inside a
block determines the weights `1/n` of these points.
"""
struct BlockWeighting{T,N} <: WeightingMethod
  sides::SVector{N,T}
end

BlockWeighting(sides::NTuple{N,T}) where {N,T} =
  BlockWeighting{T,N}(sides)

BlockWeighting(sides::Vararg) = BlockWeighting(sides)

weight(object, method::BlockWeighting) =
  weight(domain(object), method)

function weight(object::Domain, method::BlockWeighting)
  p = partition(object, BlockPartition(method.sides))

  weights = Vector{Float64}(undef, nelements(object))
  for s in subsets(p)
    n = length(s)
    weights[s] .= 1/n
  end

  GeoWeights(object, weights)
end

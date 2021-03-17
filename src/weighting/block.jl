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
struct BlockWeighting{Dim,T} <: WeightingMethod
  sides::SVector{Dim,T}
end

BlockWeighting(sides::NTuple) = BlockWeighting(SVector(sides))
BlockWeighting(sides::Vararg) = BlockWeighting(SVector(sides))

weight(object, method::BlockWeighting) =
  weight(domain(object), method)

function weight(domain::Domain, method::BlockWeighting)
  p = partition(domain, BlockPartition(method.sides))

  weights = Vector{Float64}(undef, nelements(domain))
  for s in subsets(p)
    weights[s] .= 1 / length(s)
  end

  GeoWeights(domain, weights)
end

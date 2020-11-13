# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockWeighter(sides)
    BlockWeighter(side₁, side₂, ...)

A weighting method that assigns weights to points in spatial object
based on blocks of given `sides`. The number `n` of points inside a
block determines the weights `1/n` of these points.
"""
struct BlockWeighter{T,N} <: AbstractWeighter
  sides::SVector{N,T}
end

BlockWeighter(sides::NTuple{N,T}) where {N,T} =
  BlockWeighter{T,N}(sides)

BlockWeighter(sides::Vararg) = BlockWeighter(sides)

weight(object, weighter::BlockWeighter) =
  weight(domain(object), weighter)

function weight(object::AbstractDomain, weighter::BlockWeighter)
  p = partition(object, BlockPartitioner(weighter.sides))

  weights = Vector{Float64}(undef, nelms(object))
  for s in subsets(p)
    n = length(s)
    weights[s] .= 1/n
  end

  SpatialWeights(object, weights)
end
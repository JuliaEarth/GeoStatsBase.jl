# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    BlockWeighter(side)

A weighting method that assigns weights to points in spatial object
based on blocks of given `side`. The number (n) of points inside a
block determines the weights (1/n) of these points.
"""
struct BlockWeighter{T} <: AbstractWeighter
  side::T
end

function weight(object::AbstractSpatialObject, weighter::BlockWeighter)
  p = partition(object, BlockPartitioner(weighter.side))

  weights = Vector{Float64}(undef, npoints(object))
  for s in subsets(p)
    n = length(s)
    weights[s] .= 1/n
  end

  SpatialWeights(domain(object), weights)
end

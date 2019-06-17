# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    BlockWeighter(side)

A weighting method that assigns weights to points in spatial data
based on blocks of given `side`. The number (n) of points inside a
block determines the weights (1/n) of these points.
"""
struct BlockWeighter{T} <: AbstractWeighter
  side::T
end

function weight(spatialdata::AbstractSpatialData, weighter::BlockWeighter)
  p = partition(spatialdata, BlockPartitioner(weighter.side))

  weights = Vector{Float64}(undef, npoints(spatialdata))
  for s in subsets(p)
    n = length(s)
    weights[s] .= 1/n
  end

  WeightedSpatialData(spatialdata, weights)
end

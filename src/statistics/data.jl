# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

const RealOrVec = Union{Real,AbstractVector}

"""
    mean(spatialdata)

Spatial mean of `spatialdata`.
"""
mean(d::AbstractData, v::Symbol, w::AbstractWeighter) = mean(vec(d[v]), weight(d, w))
mean(d::AbstractData, v::Symbol, blockside::Real) = mean(d, v, BlockWeighter(blockside))
mean(d::AbstractData, v::Symbol) = mean(d, v, median_heuristic(d))
mean(d::AbstractData, w::AbstractWeighter) = Dict(v => mean(d, v, w) for (v,V) in variables(d))
mean(d::AbstractData, blockside::Real) = mean(d, BlockWeighter(blockside))
mean(d::AbstractData) = mean(d, median_heuristic(d))

"""
    var(spatialdata)

Spatial variance of `spatialdata`.
"""
var(d::AbstractData, v::Symbol, w::AbstractWeighter) = var(vec(d[v]), weight(d, w), mean=mean(d, v, w), corrected=false)
var(d::AbstractData, v::Symbol, blockside::Real) = var(d, v, BlockWeighter(blockside))
var(d::AbstractData, v::Symbol) = var(d, v, median_heuristic(d))
var(d::AbstractData, w::AbstractWeighter) = Dict(v => var(d, v, w) for (v,V) in variables(d))
var(d::AbstractData, blockside::Real) = var(d, BlockWeighter(blockside))
var(d::AbstractData) = var(d, median_heuristic(d))

"""
    quantile(spatialdata, p)

Spatial quantile of `spatialdata`.
"""
quantile(d::AbstractData, v::Symbol, p::T, w::AbstractWeighter) where {T<:RealOrVec} = quantile(vec(d[v]), weight(d, w), p)
quantile(d::AbstractData, v::Symbol, p::T, blockside::Real) where {T<:RealOrVec} = quantile(d, v, p, BlockWeighter(blockside))
quantile(d::AbstractData, v::Symbol, p::T) where {T<:RealOrVec} = quantile(d, v, p, median_heuristic(d))
quantile(d::AbstractData, p::T, w::AbstractWeighter) where {T<:RealOrVec} = Dict(v => quantile(d, v, p, w) for (v,V) in variables(d))
quantile(d::AbstractData, p::T, blockside::Real) where {T<:RealOrVec} = quantile(d, p, BlockWeighter(blockside))
quantile(d::AbstractData, p::T) where {T<:RealOrVec} = quantile(d, p, median_heuristic(d))

"""
    histogram(spatialdata)

Spatial histogram of `spatialdata`.
"""
histogram(d::AbstractData, v::Symbol, w::AbstractWeighter) = fit(Histogram, vec(d[v]), weight(d, w))
histogram(d::AbstractData, v::Symbol, blockside::Real) = histogram(d, v, BlockWeighter(blockside))
histogram(d::AbstractData, v::Symbol) = histogram(d, v, median_heuristic(d))
histogram(d::AbstractData, w::AbstractWeighter) = Dict(v => histogram(d, v, w) for (v,V) in variables(d))
histogram(d::AbstractData, blockside::Real) = histogram(d, BlockWeighter(blockside))
histogram(d::AbstractData) = histogram(d, median_heuristic(d))

function median_heuristic(d::AbstractData)
  # select at most 1000 points at random
  npts = npoints(d)
  inds = sample(1:npts, min(npts, 1000), replace=false)
  X = coordinates(d, inds)
  D = pairwise(Euclidean(), X, dims=2)

  # median heuristic
  n = size(D, 1)
  m = median(D[i,j] for i in 1:n for j in 1:n if i > j)

  # bounding box constraint
  l = minimum(sides(boundbox(d)))

  min(m, l)
end

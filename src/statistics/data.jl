# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

const RealOrVec = Union{Real,AbstractVector}

#------------------------
# WEIGHTED SPATIAL DATA
#------------------------
mean(d::WeightedSpatialData, v::Symbol) = mean(d[v], weights(d.weights))
mean(d::WeightedSpatialData) = Dict(v => mean(d, v) for (v,V) in variables(d))

var(d::WeightedSpatialData, v::Symbol) = var(d[v], weights(d.weights),
                                             mean=mean(d, v), corrected=false)
var(d::WeightedSpatialData) = Dict(v => var(d, v) for (v,V) in variables(d))

quantile(d::WeightedSpatialData, v::Symbol, p::T) where {T<:RealOrVec} = quantile(d[v], weights(d.weights), p)
quantile(d::WeightedSpatialData, p::T) where {T<:RealOrVec} = Dict(v => quantile(d, v, p) for (v,V) in variables(d))

histogram(d::WeightedSpatialData, v::Symbol) = fit(Histogram, d[v], weights(d.weights))
histogram(d::WeightedSpatialData) = Dict(v => histogram(d, v) for (v,V) in variables(d))

#---------------
# SPATIAL DATA
#---------------
mean(d::AbstractData, v::Symbol, w::AbstractWeighter) = mean(weight(d, w), v)
mean(d::AbstractData, v::Symbol, blockside::Real) = mean(d, v, BlockWeighter(blockside))
mean(d::AbstractData, v::Symbol) = mean(d, v, median_heuristic(d))
mean(d::AbstractData, w::AbstractWeighter) = mean(weight(d, w))
mean(d::AbstractData, blockside::Real) = mean(d, BlockWeighter(blockside))
mean(d::AbstractData) = mean(d, median_heuristic(d))

var(d::AbstractData, v::Symbol, w::AbstractWeighter) = var(weight(d, w), v)
var(d::AbstractData, v::Symbol, blockside::Real) = var(d, v, BlockWeighter(blockside))
var(d::AbstractData, v::Symbol) = var(d, v, median_heuristic(d))
var(d::AbstractData, w::AbstractWeighter) = var(weight(d, w))
var(d::AbstractData, blockside::Real) = var(d, BlockWeighter(blockside))
var(d::AbstractData) = var(d, median_heuristic(d))

quantile(d::AbstractData, v::Symbol, p::T, w::AbstractWeighter) where {T<:RealOrVec} = quantile(weight(d, w), v, p)
quantile(d::AbstractData, v::Symbol, p::T, blockside::Real) where {T<:RealOrVec} = quantile(d, v, p, BlockWeighter(blockside))
quantile(d::AbstractData, v::Symbol, p::T) where {T<:RealOrVec} = quantile(d, v, p, median_heuristic(d))
quantile(d::AbstractData, p::T, w::AbstractWeighter) where {T<:RealOrVec} = quantile(weight(d, w), p)
quantile(d::AbstractData, p::T, blockside::Real) where {T<:RealOrVec} = quantile(d, p, BlockWeighter(blockside))
quantile(d::AbstractData, p::T) where {T<:RealOrVec} = quantile(d, p, median_heuristic(d))

histogram(d::AbstractData, v::Symbol, w::AbstractWeighter) = histogram(weight(d, w), v)
histogram(d::AbstractData, v::Symbol, blockside::Real) = histogram(d, v, BlockWeighter(blockside))
histogram(d::AbstractData, v::Symbol) = histogram(d, v, median_heuristic(d))
histogram(d::AbstractData, w::AbstractWeighter) = histogram(weight(d, w))
histogram(d::AbstractData, blockside::Real) = histogram(d, BlockWeighter(blockside))
histogram(d::AbstractData) = histogram(d, median_heuristic(d))

function median_heuristic(d::AbstractData)
  # select at most 100 points at random
  npts = npoints(d)
  inds = unique(rand(1:npts, min(npts, 100)))
  X = coordinates(d, inds)
  D = pairwise(Euclidean(), X, dims=2)

  # median heuristic
  n = size(D, 1)
  m = median(D[i,j] for i in 1:n for j in 1:n if i > j)

  # bounding box constraint
  l = minimum(sides(boundbox(d)))

  min(m, l)
end

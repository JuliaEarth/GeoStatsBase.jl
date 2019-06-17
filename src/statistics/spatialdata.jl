# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

const RealOrVec = Union{Real,AbstractVector}

#------------------------
# WEIGHTED SPATIAL DATA
#------------------------
mean(d::WeightedSpatialData, v::Symbol) = mean(values(d, v), weights(d.weights))
mean(d::WeightedSpatialData) = Dict(v => mean(d, v) for (v,V) in variables(d))

var(d::WeightedSpatialData, v::Symbol) = var(values(d, v), weights(d.weights),
                                             mean=mean(d, v), corrected=false)
var(d::WeightedSpatialData) = Dict(v => var(d, v) for (v,V) in variables(d))

quantile(d::WeightedSpatialData, v::Symbol, p::T) where {T<:RealOrVec} = quantile(values(d, v), weights(d.weights), p)
quantile(d::WeightedSpatialData, p::T) where {T<:RealOrVec} = Dict(v => quantile(d, v, p) for (v,V) in variables(d))

#---------------
# SPATIAL DATA
#---------------
mean(d::AbstractSpatialData, v::Symbol, w::AbstractWeighter) = mean(weight(d, w), v)
mean(d::AbstractSpatialData, v::Symbol, blockside::Real) = mean(d, v, BlockWeighter(blockside))
mean(d::AbstractSpatialData, v::Symbol) = mean(d, v, median_distance(d))
mean(d::AbstractSpatialData, w::AbstractWeighter) = mean(weight(d, w))
mean(d::AbstractSpatialData, blockside::Real) = mean(d, BlockWeighter(blockside))
mean(d::AbstractSpatialData) = mean(d, median_distance(d))

var(d::AbstractSpatialData, v::Symbol, w::AbstractWeighter) = var(weight(d, w), v)
var(d::AbstractSpatialData, v::Symbol, blockside::Real) = var(d, v, BlockWeighter(blockside))
var(d::AbstractSpatialData, v::Symbol) = var(d, v, median_distance(d))
var(d::AbstractSpatialData, w::AbstractWeighter) = var(weight(d, w))
var(d::AbstractSpatialData, blockside::Real) = var(d, BlockWeighter(blockside))
var(d::AbstractSpatialData) = var(d, median_distance(d))

quantile(d::AbstractSpatialData, v::Symbol, p::T, w::AbstractWeighter) where {T<:RealOrVec} = quantile(weight(d, w), v, p)
quantile(d::AbstractSpatialData, v::Symbol, p::T, blockside::Real) where {T<:RealOrVec} = quantile(d, v, p, BlockWeighter(blockside))
quantile(d::AbstractSpatialData, v::Symbol, p::T) where {T<:RealOrVec} = quantile(d, v, p, median_distance(d))
quantile(d::AbstractSpatialData, p::T, w::AbstractWeighter) where {T<:RealOrVec} = quantile(weight(d, w), p)
quantile(d::AbstractSpatialData, p::T, blockside::Real) where {T<:RealOrVec} = quantile(d, p, BlockWeighter(blockside))
quantile(d::AbstractSpatialData, p::T) where {T<:RealOrVec} = quantile(d, p, median_distance(d))

function median_distance(d::AbstractSpatialData)
  # select at most 100 points at random
  N = npoints(d)
  inds = unique(rand(1:N, min(N, 100)))
  X = coordinates(d, inds)
  D = pairwise(Euclidean(), X, dims=2)

  median(D)
end

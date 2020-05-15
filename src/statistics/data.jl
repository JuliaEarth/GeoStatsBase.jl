# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

const RealOrVec = Union{Real,AbstractVector}

"""
    mean(spatialdata)

Spatial mean of `spatialdata`.
"""
mean(d::AbstractData, v::Symbol, w::AbstractWeighter) = mean(vec(d[v]), weight(d, w))
mean(d::AbstractData, v::Symbol, side::Real) = mean(d, v, BlockWeighter(ntuple(i->side,ndims(d))))
mean(d::AbstractData, v::Symbol) = mean(d, v, median_heuristic(d))
mean(d::AbstractData, w::AbstractWeighter) = Dict(v => mean(d, v, w) for (v,V) in variables(d))
mean(d::AbstractData, side::Real) = mean(d, BlockWeighter(ntuple(i->side,ndims(d))))
mean(d::AbstractData) = mean(d, median_heuristic(d))

"""
    var(spatialdata)

Spatial variance of `spatialdata`.
"""
var(d::AbstractData, v::Symbol, w::AbstractWeighter) = var(vec(d[v]), weight(d, w), mean=mean(d, v, w), corrected=false)
var(d::AbstractData, v::Symbol, side::Real) = var(d, v, BlockWeighter(ntuple(i->side,ndims(d))))
var(d::AbstractData, v::Symbol) = var(d, v, median_heuristic(d))
var(d::AbstractData, w::AbstractWeighter) = Dict(v => var(d, v, w) for (v,V) in variables(d))
var(d::AbstractData, side::Real) = var(d, BlockWeighter(ntuple(i->side,ndims(d))))
var(d::AbstractData) = var(d, median_heuristic(d))

"""
    quantile(spatialdata, p)

Spatial quantile of `spatialdata`.
"""
quantile(d::AbstractData, v::Symbol, p::T, w::AbstractWeighter) where {T<:RealOrVec} = quantile(vec(d[v]), weight(d, w), p)
quantile(d::AbstractData, v::Symbol, p::T, side::Real) where {T<:RealOrVec} = quantile(d, v, p, BlockWeighter(ntuple(i->side,ndims(d))))
quantile(d::AbstractData, v::Symbol, p::T) where {T<:RealOrVec} = quantile(d, v, p, median_heuristic(d))
quantile(d::AbstractData, p::T, w::AbstractWeighter) where {T<:RealOrVec} = Dict(v => quantile(d, v, p, w) for (v,V) in variables(d))
quantile(d::AbstractData, p::T, side::Real) where {T<:RealOrVec} = quantile(d, p, BlockWeighter(ntuple(i->side,ndims(d))))
quantile(d::AbstractData, p::T) where {T<:RealOrVec} = quantile(d, p, median_heuristic(d))

"""
    EmpiricalHistogram(spatialdata)

Spatial histogram of `spatialdata`.
"""
EmpiricalHistogram(d::AbstractData, v::Symbol, w::AbstractWeighter) = fit(Histogram, vec(d[v]), weight(d, w))
EmpiricalHistogram(d::AbstractData, v::Symbol, side::Real) = EmpiricalHistogram(d, v, BlockWeighter(ntuple(i->side,ndims(d))))
EmpiricalHistogram(d::AbstractData, v::Symbol) = EmpiricalHistogram(d, v, median_heuristic(d))
EmpiricalHistogram(d::AbstractData, w::AbstractWeighter) = Dict(v => EmpiricalHistogram(d, v, w) for (v,V) in variables(d))
EmpiricalHistogram(d::AbstractData, side::Real) = EmpiricalHistogram(d, BlockWeighter(ntuple(i->side,ndims(d))))
EmpiricalHistogram(d::AbstractData) = EmpiricalHistogram(d, median_heuristic(d))

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

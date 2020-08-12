# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

mean(d, v::Symbol, w::AbstractWeighter) = mean(d[v], weight(d, w))
mean(d, v::Symbol, s::Number) = mean(d, v, BlockWeighter(ntuple(i->s,ndims(d))))
mean(d, v::Symbol) = mean(d, v, median_heuristic(d))
mean(d, w::AbstractWeighter) = Dict(v => mean(d, v, w) for v in name.(variables(d)))
mean(d, s::Number) = mean(d, BlockWeighter(ntuple(i->s,ndims(d))))

"""
    mean(sdata)
    mean(sdata, v)
    mean(sdata, v, s)

Spatial mean of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
mean(d::AbstractData) = mean(d, median_heuristic(d))

var(d, v::Symbol, w::AbstractWeighter) = var(d[v], weight(d, w), mean=mean(d, v, w), corrected=false)
var(d, v::Symbol, s::Number) = var(d, v, BlockWeighter(ntuple(i->s,ndims(d))))
var(d, v::Symbol) = var(d, v, median_heuristic(d))
var(d, w::AbstractWeighter) = Dict(v => var(d, v, w) for v in name.(variables(d)))
var(d, s::Number) = var(d, BlockWeighter(ntuple(i->s,ndims(d))))

"""
    var(sdata)
    var(sdata, v)
    var(sdata, v, s)

Spatial variance of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
var(d::AbstractData) = var(d, median_heuristic(d))

quantile(d, v::Symbol, p, w::AbstractWeighter) = quantile(d[v], weight(d, w), p)
quantile(d, v::Symbol, p, s::Number) = quantile(d, v, p, BlockWeighter(ntuple(i->s,ndims(d))))
quantile(d, v::Symbol, p) = quantile(d, v, p, median_heuristic(d))
quantile(d, p, w::AbstractWeighter) = Dict(v => quantile(d, v, p, w) for v in name.(variables(d)))
quantile(d, p::T, s::Number) where {T<:Union{Number,AbstractVector}} = quantile(d, p, BlockWeighter(ntuple(i->s,ndims(d))))

"""
    quantile(sdata, p)
    quantile(sdata, v, p)
    quantile(sdata, v, p, s)

Spatial quantile of spatial data `sdata` at probability `p`.
Optionally, specify the variable `v` and the block side `s`.
"""
quantile(d::AbstractData, p) = quantile(d, p, median_heuristic(d))

"""
    EmpiricalHistogram(sdata)

Spatial histogram of spatial data `sdata`.
"""
EmpiricalHistogram(d, v::Symbol, w::AbstractWeighter) = fit(Histogram, d[v], weight(d, w))
EmpiricalHistogram(d, v::Symbol, s::Number) = EmpiricalHistogram(d, v, BlockWeighter(ntuple(i->s,ndims(d))))
EmpiricalHistogram(d, v::Symbol) = EmpiricalHistogram(d, v, median_heuristic(d))
EmpiricalHistogram(d, w::AbstractWeighter) = Dict(v => EmpiricalHistogram(d, v, w) for v in name.(variables(d)))
EmpiricalHistogram(d, s::Number) = EmpiricalHistogram(d, BlockWeighter(ntuple(i->s,ndims(d))))
EmpiricalHistogram(d) = EmpiricalHistogram(d, median_heuristic(d))

function median_heuristic(d)
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

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

mean(d, v::Symbol, w::WeightingMethod) = mean(d[v], weight(d, w))
mean(d, v::Symbol, s::Number) = mean(d, v, BlockWeighting(ntuple(i->s,embeddim(d))))
mean(d, v::Symbol) = mean(d, v, mode_heuristic(d))
mean(d, w::WeightingMethod) = Dict(v => mean(d, v, w) for v in name.(variables(d)))
mean(d, s::Number) = mean(d, BlockWeighting(ntuple(i->s,embeddim(d))))

"""
    mean(sdata)
    mean(sdata, v)
    mean(sdata, v, s)

Spatial mean of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
mean(d::Data) = mean(d, mode_heuristic(d))

var(d, v::Symbol, w::WeightingMethod) = var(d[v], weight(d, w), mean=mean(d, v, w), corrected=false)
var(d, v::Symbol, s::Number) = var(d, v, BlockWeighting(ntuple(i->s,embeddim(d))))
var(d, v::Symbol) = var(d, v, mode_heuristic(d))
var(d, w::WeightingMethod) = Dict(v => var(d, v, w) for v in name.(variables(d)))
var(d, s::Number) = var(d, BlockWeighting(ntuple(i->s,embeddim(d))))

"""
    var(sdata)
    var(sdata, v)
    var(sdata, v, s)

Spatial variance of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
var(d::Data) = var(d, mode_heuristic(d))

quantile(d, v::Symbol, p, w::WeightingMethod) = quantile(d[v], weight(d, w), p)
quantile(d, v::Symbol, p, s::Number) = quantile(d, v, p, BlockWeighting(ntuple(i->s,embeddim(d))))
quantile(d, v::Symbol, p) = quantile(d, v, p, mode_heuristic(d))
quantile(d, p, w::WeightingMethod) = Dict(v => quantile(d, v, p, w) for v in name.(variables(d)))
quantile(d, p::T, s::Number) where {T<:Union{Number,AbstractVector}} = quantile(d, p, BlockWeighting(ntuple(i->s,embeddim(d))))

"""
    quantile(sdata, p)
    quantile(sdata, v, p)
    quantile(sdata, v, p, s)

Spatial quantile of spatial data `sdata` at probability `p`.
Optionally, specify the variable `v` and the block side `s`.
"""
quantile(d::Data, p) = quantile(d, p, mode_heuristic(d))

function dist_matrix_random_sample(d, npoints=1000)
  # select at most 1000 points at random
  nel = nelements(d)
  inds = sample(1:nel, min(nel, npoints), replace=false)
  X = (coordinates(centroid(d, ind)) for ind in inds)
  pairwise(Euclidean(), X)
end

bound_box_constr(d) = minimum(sides(boundingbox(domain(d))))

function median_heuristic(d)
  D = dist_matrix_random_sample(d)
  # median heuristic
  n = size(D, 1)
  m = median(D[i,j] for i in 1:n for j in 1:n if i > j)

  l = bound_box_constr(d)

  min(m, l)
end

"""
    mode_heuristic(d)

Return the estimated mode of the pairwise distances for a set of locations.
"""
function mode_heuristic(d)
  D = dist_matrix_random_sample(d)
  n = size(D, 1)
  δ = [D[i,j] for i in 1:n for j in 1:n if i > j]
  m = hsm_mode(δ)
  l = bound_box_constr(d)
  min(m, l)
end

"""
    hsm_mode(x)

Return the mode of the vector `x`.

## References

* Bickel & Frühwirth, 2005. [On a fast, robust estimator
  of the mode: Comparisons to other robust estimators
  with applications](https://doi.org/10.1016/j.csda.2005.07.011)
"""
hsm_mode(x) = hsm_recursion(sort(x))

function hsm_recursion(x)
  n = length(x)

  # base cases
  n == 1 && return x[1]
  n == 2 && return (x[1] + x[2]) / 2
  if n == 3
    d1 = x[2] - x[1]
    d2 = x[3] - x[2]
    d1 < d2 && return (x[1] + x[2]) / 2
    d1 > d2 && return (x[2] + x[3]) / 2
    d1 == d2 && return x[2]
  end

  # find index of half interval
  k = ceil(Int, n / 2)
  i = argmin([x[j+k] - x[j] for j in 1:n-k])

  # perform recursion
  hsm_recursion(view(x, i:i+k))
end

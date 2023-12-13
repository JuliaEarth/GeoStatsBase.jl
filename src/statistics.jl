# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    mean(data)
    mean(data, v)
    mean(data, v, s)

Declustered mean of geospatial `data`. Optionally,
specify the variable `v` and the block side `s`.
"""
mean(t::AbstractGeoTable) = Dict(v => mean(t, v, mode_heuristic(t)) for v in setdiff(propertynames(t), [:geometry]))
mean(t::AbstractGeoTable, v) = mean(t, v, mode_heuristic(t))
mean(t::AbstractGeoTable, v, s::Number) = mean(t, v, BlockWeighting(s))
mean(t::AbstractGeoTable, v, w::WeightingMethod) = mean(getproperty(t, v), weight(t, w))

"""
    var(data)
    var(data, v)
    var(data, v, s)

Declustered variance of geospatial `data`. Optionally,
specify the variable `v` and the block side `s`.
"""
var(t::AbstractGeoTable) = Dict(v => var(t, v, mode_heuristic(t)) for v in setdiff(propertynames(t), [:geometry]))
var(t::AbstractGeoTable, v) = var(t, v, mode_heuristic(t))
var(t::AbstractGeoTable, v, s::Number) = var(t, v, BlockWeighting(s))
var(t::AbstractGeoTable, v, w::WeightingMethod) = var(getproperty(t, v), weight(t, w), mean=mean(t, v, w), corrected=false)

"""
    quantile(data, p)
    quantile(data, v, p)
    quantile(data, v, p, s)

Declustered quantile of geospatial `data` at probability `p`.
Optionally, specify the variable `v` and the block side `s`.
"""
quantile(t::AbstractGeoTable, p) =
  Dict(v => quantile(t, v, p, mode_heuristic(t)) for v in setdiff(propertynames(t), [:geometry]))
quantile(t::AbstractGeoTable, v, p) = quantile(t, v, p, mode_heuristic(t))
quantile(t::AbstractGeoTable, v, p, s::Number) = quantile(t, v, p, BlockWeighting(s))
quantile(t::AbstractGeoTable, v, p, w::WeightingMethod) = quantile(getproperty(t, v), weight(t, w), p)

# return a block size based on pairwise distances and
# an aggregation function (e.g. mean, mode)
function heuristic(t, fun)
  𝒟 = domain(t)
  D = dist_matrix_random_sample(𝒟)
  n = size(D, 1)
  d = fun([D[i, j] for i in 1:n for j in 1:n if i > j])
  l = bound_box_constr(𝒟)
  min(d, l)
end

median_heuristic(t) = heuristic(t, median)

mode_heuristic(t) = heuristic(t, hsm_mode)

function dist_matrix_random_sample(𝒟)
  # select a maximum number of points at random
  nobs = nelements(𝒟)
  inds = sample(1:nobs, min(nobs, 1000), replace=false)
  X = (coordinates(centroid(𝒟, ind)) for ind in inds)
  pairwise(Euclidean(), X)
end

bound_box_constr(𝒟) = minimum(sides(boundingbox(𝒟)))

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
  i = argmin([x[j + k] - x[j] for j in 1:(n - k)])

  # perform recursion
  hsm_recursion(view(x, i:(i + k)))
end

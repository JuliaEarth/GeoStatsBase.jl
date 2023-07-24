# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

mean(d, v::Symbol, w::WeightingMethod) = mean(getproperty(d, v), weight(d, w))
mean(d, v::Symbol, s::Number) = mean(d, v, BlockWeighting(s))
mean(d, v::Symbol) = mean(d, v, mode_heuristic(d))

"""
    mean(data)
    mean(data, v)
    mean(data, v, s)

Declustered mean of geospatial `data`. Optionally,
specify the variable `v` and the block side `s`.
"""
mean(d::Data) = Dict(v => mean(d, v, mode_heuristic(d)) for v in name.(variables(d)))

var(d, v::Symbol, w::WeightingMethod) = var(getproperty(d, v), weight(d, w), mean=mean(d, v, w), corrected=false)
var(d, v::Symbol, s::Number) = var(d, v, BlockWeighting(s))
var(d, v::Symbol) = var(d, v, mode_heuristic(d))

"""
    var(data)
    var(data, v)
    var(data, v, s)

Declustered variance of geospatial `data`. Optionally,
specify the variable `v` and the block side `s`.
"""
var(d::Data) = Dict(v => var(d, v, mode_heuristic(d)) for v in name.(variables(d)))

quantile(d, v::Symbol, p, w::WeightingMethod) = quantile(getproperty(d, v), weight(d, w), p)
quantile(d, v::Symbol, p, s::Number) = quantile(d, v, p, BlockWeighting(s))
quantile(d, v::Symbol, p) = quantile(d, v, p, mode_heuristic(d))

"""
    quantile(data, p)
    quantile(data, v, p)
    quantile(data, v, p, s)

Declustered quantile of geospatial `data` at probability `p`.
Optionally, specify the variable `v` and the block side `s`.
"""
quantile(d::Data, p) = Dict(v => quantile(d, v, p, mode_heuristic(d)) for v in name.(variables(d)))

# return a block size based on pairwise distances and
# an aggregation function (e.g. mean, mode)
function heuristic(d, fun)
  𝒟 = domain(d)
  D = dist_matrix_random_sample(𝒟)
  n = size(D, 1)
  d = fun([D[i, j] for i in 1:n for j in 1:n if i > j])
  l = bound_box_constr(𝒟)
  min(d, l)
end

median_heuristic(d) = heuristic(d, median)

mode_heuristic(d) = heuristic(d, hsm_mode)

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

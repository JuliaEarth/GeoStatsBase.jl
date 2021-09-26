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

Return the estimated mode of the inter-point distances for a set of locations.

## References

* Bickel & Frühwirth, 2005. [On a fast, robust estimator
  of the mode: Comparisons to other robust estimators
  with applications](https://doi.org/10.1016/j.csda.2005.07.011)
"""
function mode_heuristic(d)
  D = dist_matrix_random_sample(d)
  n = size(D, 1)
  x_n = sort([D[i,j] for i in 1:n for j in 1:n if i > j])

  while length(x_n) ≥ 4
    n = length(x_n)
    k = trunc(Int, ceil(n / 2) - 1)

    inf = x_n[1:(n - k)]
    sup = x_n[(k + 1):n]
    diffs = sup - inf
    i = argmin(diffs)
    if diffs[i] == 0
      x_n = [x_n[i]]
    else
      x_n = x_n[i:(i+k)]
    end
  end

  if length(x_n) == 3
    # must determine if the center value x_n[2] is closer
    # to the smaller value x_n[1] or larger value x_n[3]
    dif = 2*x_n[2] - x_n[1] - x_n[3]

    if (dif > 0)
      # x_n[2] is closer to larger value x_n[3]
      m = (x_n[2] + x_n[3]) / 2
    elseif (dif < 0)
      # x_n[2] is closer to smaller value x_n[1]
      m = (x_n[1] + x_n[2]) / 2
    else
      # equidistant
      m = x_n[2]
    end
  else
    # if x_n has length 1 or 2, simply take the mean of the vector
    m = mean(x_n)
  end

  l = bound_box_constr(d)

  min(m, l)
end

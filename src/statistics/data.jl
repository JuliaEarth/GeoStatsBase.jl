# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

mean(d, v::Symbol, w::WeightingMethod) = mean(d[v], weight(d, w))
mean(d, v::Symbol, s::Number) = mean(d, v, BlockWeighting(ntuple(i->s,embeddim(d))))
mean(d, v::Symbol) = mean(d, v, median_heuristic(d))
mean(d, w::WeightingMethod) = Dict(v => mean(d, v, w) for v in name.(variables(d)))
mean(d, s::Number) = mean(d, BlockWeighting(ntuple(i->s,embeddim(d))))

"""
    mean(sdata)
    mean(sdata, v)
    mean(sdata, v, s)

Spatial mean of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
mean(d::Data) = mean(d, median_heuristic(d))

var(d, v::Symbol, w::WeightingMethod) = var(d[v], weight(d, w), mean=mean(d, v, w), corrected=false)
var(d, v::Symbol, s::Number) = var(d, v, BlockWeighting(ntuple(i->s,embeddim(d))))
var(d, v::Symbol) = var(d, v, median_heuristic(d))
var(d, w::WeightingMethod) = Dict(v => var(d, v, w) for v in name.(variables(d)))
var(d, s::Number) = var(d, BlockWeighting(ntuple(i->s,embeddim(d))))

"""
    var(sdata)
    var(sdata, v)
    var(sdata, v, s)

Spatial variance of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
var(d::Data) = var(d, median_heuristic(d))

quantile(d, v::Symbol, p, w::WeightingMethod) = quantile(d[v], weight(d, w), p)
quantile(d, v::Symbol, p, s::Number) = quantile(d, v, p, BlockWeighting(ntuple(i->s,embeddim(d))))
quantile(d, v::Symbol, p) = quantile(d, v, p, median_heuristic(d))
quantile(d, p, w::WeightingMethod) = Dict(v => quantile(d, v, p, w) for v in name.(variables(d)))
quantile(d, p::T, s::Number) where {T<:Union{Number,AbstractVector}} = quantile(d, p, BlockWeighting(ntuple(i->s,embeddim(d))))

"""
    quantile(sdata, p)
    quantile(sdata, v, p)
    quantile(sdata, v, p, s)

Spatial quantile of spatial data `sdata` at probability `p`.
Optionally, specify the variable `v` and the block side `s`.
"""
quantile(d::Data, p) = quantile(d, p, median_heuristic(d))


function dist_matrix_random_sample(d, npoints=1000)

  # select at most 1000 points at random
  nel = nelements(d)
  inds = sample(1:nel, min(nel, 1000), replace=false)
  X = (coordinates(centroid(d, ind)) for ind in inds)
  pairwise(Euclidean(), X)
end

function median_heuristic(d)

  D = dist_matrix_random_sample(d)

  # median heuristic
  n = size(D, 1)
  m = median(D[i,j] for i in 1:n for j in 1:n if i > j)

  # bounding box constraint
  l = minimum(sides(boundingbox(domain(d))))

  min(m, l)
end

function mode_heuristic(d)

  D = dist_matrix_random_sample(d)
  n = size(D, 1)
  D_upper_sorted = sort(collect(D[i,j] for i in 1:n for j in 1:n if i > j))

  x_n = D_upper_sorted

  while length(x_n) ≥ 4

    n = length(x_n)
    k = trunc(Int, ceil(n / 2) - 1)

    inf = x_n[begin:(n - k)]
    sup = x_n[(k + 1):n]
    diffs = sup - inf
    i = argmin(diffs)
    if diffs[i] == 0
        x_n = [x_n[i]]
    else
        x_n = x_n[i:(i+k)]
    end

  end

  if length(x_n) == 1
    m = x_n[1]
  elseif length(x_n) == 2
    m = mean(x_n)
  elseif length(x_n) == 3
    difs = map(abs, [x_n[1] - x_n[2], x_n[1] - x_n[2], x_n[2] - x_n[3]])
    m = [x_n[2], mean(x_n[1:2]), mean(x_n[2:3])][argmin(difs)]
  end

  # bounding box constraint
  l = minimum(sides(boundingbox(domain(d))))

  min(m, l)
end

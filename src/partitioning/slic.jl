# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SLICPartition(k, m; tol=1e-4, maxiter=10, vars=nothing)

A method for partitioning spatial data into approximately `k`
clusters using Simple Linear Iterative Clustering (SLIC).
The method produces clusters of samples that are spatially
connected based on a distance `dₛ` and that, at the same
time, are similar in terms of `vars` with distance `dᵥ`.
The tradeoff is controlled with a hyperparameter parameter
`m` in an additive model `dₜ = √(dᵥ² + m²(dₛ/s)²)`.

## Parameters

* `k`       - Approximate number of clusters
* `m`       - Hyperparameter of SLIC model
* `tol`     - Tolerance of k-means algorithm (default to `1e-4`)
* `maxiter` - Maximum number of iterations (default to `10`)
* `vars`    - Variables (or features) to consider (default to all)

## References

* Achanta et al. 2011. [SLIC superpixels compared to state-of-the-art
  superpixel methods](https://ieeexplore.ieee.org/document/6205760)
"""
struct SLICPartition <: PartitionMethod
  k::Int
  m::Float64
  tol::Float64
  maxiter::Int
  vars::Union{Vector{Symbol},Nothing}
end

SLICPartition(k::Int, m::Real; tol=1e-4, maxiter=10, vars=nothing) =
  SLICPartition(k, m, tol, maxiter, vars)

function partition(sdata, method::SLICPartition)
  # variables used for clustering
  datavars = collect(name.(variables(sdata)))
  vars = isnothing(method.vars) ? datavars : method.vars

  @assert vars ⊆ datavars "SLIC features not found in spatial data"

  # SLIC hyperparameter
  m = method.m

  # initial spacing of clusters
  s = slic_spacing(sdata, method)

  # initialize cluster centers
  c = slic_initialization(sdata, s)

  # ball neighborhood search
  searcher = NeighborhoodSearch(sdata, BallNeighborhood(s))

  # pre-allocate memory for label and distance
  l = fill(0, nelms(sdata))
  d = fill(Inf, nelms(sdata))

  # performance parameters
  tol     = method.tol
  maxiter = method.maxiter

  # k-means algorithm
  err, iter = Inf, 0
  while err > tol && iter < maxiter
    o = copy(c)

    slic_assignment!(sdata, searcher, vars, m, s, c, l, d)
    slic_update!(sdata, c, l)

    err = norm(c - o) / norm(o)
    iter += 1
  end

  subsets = [findall(isequal(k), l) for k in 1:length(c)]

  SpatialPartition(sdata, subsets)
end

function slic_spacing(sdata, method)
  V = volume(boundbox(sdata))
  d = ncoords(sdata)
  k = method.k
  (V/k) ^ (1/d)
end

function slic_initialization(sdata, s)
  # efficient neighbor search
  searcher = KNearestSearch(sdata, 1)

  # bounding box properties
  bbox = boundbox(sdata)
  lo, up = extrema(bbox)

  # cluster centers
  clusters = Vector{Int}()
  neighbor = Vector{Int}(undef, 1)
  ranges = [(l+s/2):s:u for (l, u) in zip(lo, up)]
  for x in Iterators.product(ranges...)
    search!(neighbor, SVector(x), searcher)
    push!(clusters, neighbor[1])
  end

  unique(clusters)
end

function slic_assignment!(sdata, searcher, vars, m, s, c, l, d)
  for (k, cₖ) in enumerate(c)
    xₖ = coordinates(sdata, [cₖ])
    inds = search(vec(xₖ), searcher)

    # distance between coordinates
    X  = coordinates(sdata, inds)
    dₛ = pairwise(Euclidean(), X, xₖ, dims=2)

    # distance between variables
    𝒮ᵢ = view(sdata, inds, vars)
    𝒮ₖ = view(sdata, [cₖ], vars)
    V  = Tables.matrix(values(𝒮ᵢ))
    vₖ = Tables.matrix(values(𝒮ₖ))
    dᵥ = pairwise(Euclidean(), V, vₖ, dims=1)

    # total distance
    dₜ = @. √(dᵥ^2 + m^2 * (dₛ/s)^2)

    @inbounds for (i, ind) in enumerate(inds)
      if dₜ[i] < d[ind]
        d[ind] = dₜ[i]
        l[ind] = k
      end
    end
  end
end

function slic_update!(sdata, c, l)
  for k in 1:length(c)
    inds = findall(isequal(k), l)
    X  = coordinates(sdata, inds)
    μ  = mean(X, dims=2)
    dₛ = pairwise(Euclidean(), X, μ, dims=2)
    @inbounds c[k] = inds[argmin(vec(dₛ))]
  end
end

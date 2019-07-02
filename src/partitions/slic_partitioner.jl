# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SLICPartitioner(k, m, [features])

A method for partitioning spatial data into approximately `k`
clusters using Simple Linear Iterative Clustering (SLIC).
The method produces clusters of samples that are spatially
connected based on a distance `dₛ` and that, at the same
time, are similar in terms of `features` with distance `dₓ`.
The tradeoff is controlled with a weight parameter `m` in
an additive model `d = √(dₓ² + m²dₛ²)`.
"""
struct SLICPartitioner <: AbstractPartitioner
  k::Int
  m::Float64
  features::Union{Vector{Symbol},Nothing}
end

SLICPartitioner(k::Int, m::Real) = SLICPartitioner(k, m, nothing)

function partition(spatialdata::AbstractData, partitioner::SLICPartitioner)
  V = boundvolume(spatialdata)
  n = npoints(spatialdata)
  N = ndims(spatialdata)
  k = partitioner.k
  s = (V/k) ^ (1/N)

  # initialize cluster centers
  c = slic_initialization(spatialdata, s)

  # ball neighborhood for local search
  neigh = BallNeighborhood(spatialdata, s)

  # pre-allocate memory for label and distance
  l = fill(0, n); d = fill(Inf, n)

  # k-means algorithm
  err, iter = Inf, 0
  while iter < 10 # TODO: add err > threshold condition
    slic_assignment!(spatialdata, neigh, c, d, l)
    slic_update!(spatialdata, c, l)
    # TODO: compute error
    iter += 1
  end

  subsets = [findall(isequal(k), l) for k in 1:length(c)]

  SpatialPartition(spatialdata, subsets)
end

function slic_initialization(spatialdata::AbstractData, s::Real)
  # efficient neighbor search
  searcher = NearestNeighborSearcher(spatialdata, 1)

  # cluster centers
  clusters = Vector{Int}()
  neighbor = Vector{Int}(undef, 1)
  ranges = [lo:s:up for (lo,up) in bounds(spatialdata)]
  for x in Iterators.product(ranges...)
    search!(neighbor, SVector(x), searcher)
    push!(clusters, neighbor[1])
  end

  unique(clusters)
end

function slic_assignment!(spatialdata::AbstractData,
                          neigh::BallNeighborhood,
                          c::AbstractVector{Int},
                          d::AbstractVector{Float64},
                          l::AbstractVector{Int})
  for (k, cₖ) in enumerate(c)
    inds = neigh(cₖ)
    X  = coordinates(spatialdata, inds)
    xₖ = coordinates(spatialdata, [cₖ])
    dₛ = pairwise(Euclidean(), X, xₖ, dims=2)
    @inbounds for (i, ind) in enumerate(inds)
      if dₛ[i] < d[ind]
        d[ind] = dₛ[i]
        l[ind] = k
      end
    end
  end
end

function slic_update!(spatialdata::AbstractData,
                      c::AbstractVector{Int},
                      l::AbstractVector{Int})
  for k in 1:length(c)
    inds = findall(isequal(k), l)
    X  = coordinates(spatialdata, inds)
    μ  = mean(X, dims=2)
    dₛ = pairwise(Euclidean(), X, μ, dims=2)
    @inbounds c[k] = argmin(vec(dₛ))
  end
end

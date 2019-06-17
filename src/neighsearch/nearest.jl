# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    NearestNeighborSearcher(domain, locations, K, metric)

A search method that finds `K` nearest neighbors in `domain`
`locations` according to `metric`.
"""
struct NearestNeighborSearcher{KD<:KDTree} <: AbstractNeighborSearcher
  kdtree::KD
  K::Int
  locs::Vector{Int}
end

function NearestNeighborSearcher(domain::AbstractDomain, locs::AbstractVector{Int}, K::Int, metric::Metric)
  @assert 1 ≤ K ≤ length(locs) "number of neighbors must be smaller than number of data locations"
  @assert length(locs) ≤ npoints(domain) "number of data locations must be smaller than number of points"
  kdtree = KDTree(coordinates(domain, locs), metric)
  NearestNeighborSearcher{typeof(kdtree)}(kdtree, K, locs)
end

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector{T},
                 searcher::NearestNeighborSearcher, mask::AbstractVector{Bool}) where {T,N}
  K       = searcher.K
  inds, _ = knn(searcher.kdtree, xₒ, K, true)
  locs    = view(searcher.locs, inds)

  @inbounds for i in 1:K
    neighbors[i] = locs[i]
  end

  K
end

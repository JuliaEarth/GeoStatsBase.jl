# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    NearestNeighborSearcher(object, locations, k, metric)

A search method that finds `k` nearest neighbors in spatial `object`
`locations` according to `metric`.
"""
struct NearestNeighborSearcher{KD<:KDTree} <: AbstractNeighborSearcher
  kdtree::KD
  k::Int
  locs::Vector{Int}
end

function NearestNeighborSearcher(object::AbstractSpatialObject,
                                 locs::AbstractVector{Int}, k::Int, metric::Metric)
  @assert 1 ≤ k ≤ length(locs) "number of neighbors must be smaller than number of data locations"
  @assert length(locs) ≤ npoints(object) "number of data locations must be smaller than number of points"
  kdtree = KDTree(coordinates(object, locs), metric)
  NearestNeighborSearcher{typeof(kdtree)}(kdtree, k, locs)
end

NearestNeighborSearcher(object::AbstractSpatialObject, k::Int, metric::Metric) =
  NearestNeighborSearcher(object, 1:npoints(object), k, metric)

NearestNeighborSearcher(object::AbstractSpatialObject, k::Int) =
  NearestNeighborSearcher(object, k, Euclidean())

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector{T},
                 searcher::NearestNeighborSearcher; mask=nothing) where {T,N}
  k       = searcher.k
  inds, _ = knn(searcher.kdtree, xₒ, k, true)
  locs    = view(searcher.locs, inds)

  @inbounds for i in 1:k
    neighbors[i] = locs[i]
  end

  k
end

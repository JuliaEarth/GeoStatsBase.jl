# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    NearestNeighborSearcher(object, k; locations=all, metric=Euclidean())

A method for searching `k` nearest neighbors in spatial `object`
`locations` according to `metric`.
"""
struct NearestNeighborSearcher{KD<:KDTree} <: AbstractBoundedNeighborSearcher
  kdtree::KD
  k::Int
  locations::Vector{Int}
end

function NearestNeighborSearcher(object::AbstractSpatialObject, k::Int;
                                 locations=1:npoints(object), metric=Euclidean())
  @assert 1 ≤ k ≤ length(locations) "number of neighbors must be smaller than number of locations"
  @assert locations ⊆ 1:npoints(object) "invalid locations for spatial object"
  kdtree = KDTree(coordinates(object, locations), metric)
  NearestNeighborSearcher{typeof(kdtree)}(kdtree, k, locations)
end

maxneighbors(searcher::NearestNeighborSearcher) = searcher.k

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
                 searcher::NearestNeighborSearcher; mask=nothing)
  k       = searcher.k
  inds, _ = knn(searcher.kdtree, xₒ, k, true)
  locs    = view(searcher.locations, inds)

  if mask ≠ nothing
    nneigh = 0
    @inbounds for i in 1:k
      if mask[locs[i]]
        nneigh += 1
        neighbors[nneigh] = locs[i]
      end
    end
  else
    nneigh = k
    @inbounds for i in 1:k
      neighbors[i] = locs[i]
    end
  end

  nneigh
end

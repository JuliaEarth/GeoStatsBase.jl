# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KBallSearcher(object, k, ball; locations)

A method that searches `k` nearest neighbors and then filters
these neighbors using a norm `ball`.
"""
struct KBallSearcher{O,B,K} <: AbstractBoundedNeighborSearcher
  # input fields
  object::O
  k::Int
  ball::B
  locations::Vector{Int}

  # state fields
  kdtree::K
end


function KBallSearcher(object::O, k::Int, ball::B; locations=1:nelms(object)) where {O,B}
  @assert 1 ≤ k ≤ length(locations) "number of neighbors must be smaller than number of locations"
  @assert locations ⊆ 1:nelms(object) "invalid locations for spatial object"
  kdtree = KDTree(coordinates(object, locations), metric(ball))
  KBallSearcher{O,B,typeof(kdtree)}(object, k, ball, locations, kdtree)
end

maxneighbors(searcher::KBallSearcher) = searcher.k

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
                 searcher::KBallSearcher; mask=nothing)
  k = searcher.k
  r = radius(searcher.ball)

  inds, dists = knn(searcher.kdtree, xₒ, k, true)
  locs = view(searcher.locations, inds)

  # keep neighbors inside ball
  keep = dists .≤ r

  # possibly mask some of the neighbors
  isnothing(mask) || (keep .*= mask[locs])

  nneigh = 0
  @inbounds for i in 1:k
    if keep[i]
      nneigh += 1
      neighbors[nneigh] = locs[i]
    end
  end

  nneigh
end
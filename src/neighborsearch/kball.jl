# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KBallSearcher(object, k, ball)

A method that searches `k` nearest neighbors and then filters
these neighbors using a norm `ball`.
"""
struct KBallSearcher{O,B,K} <: AbstractBoundedNeighborSearcher
  # input fields
  object::O
  k::Int
  ball::B

  # state fields
  kdtree::K
end


function KBallSearcher(object::O, k::Int, ball::B) where {O,B}
  kdtree = KDTree(coordinates(object), metric(ball))
  KBallSearcher{O,B,typeof(kdtree)}(object, k, ball, kdtree)
end

maxneighbors(searcher::KBallSearcher) = searcher.k

function search!(neighbors, xₒ::AbstractVector,
                 searcher::KBallSearcher; mask=nothing)
  k = searcher.k
  r = radius(searcher.ball)

  inds, dists = knn(searcher.kdtree, xₒ, k, true)

  # keep neighbors inside ball
  keep = dists .≤ r

  # possibly mask some of the neighbors
  isnothing(mask) || (keep .*= mask[inds])

  nneigh = 0
  @inbounds for i in 1:k
    if keep[i]
      nneigh += 1
      neighbors[nneigh] = inds[i]
    end
  end

  nneigh
end
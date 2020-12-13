# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KBallSearch(object, k, ball)

A method that searches `k` nearest neighbors and then filters
these neighbors using a norm `ball`.
"""
struct KBallSearch{O,B,T} <: BoundedNeighborSearchMethod
  # input fields
  object::O
  k::Int
  ball::B

  # state fields
  tree::T
end

function KBallSearch(object::O, k::Int, ball::B) where {O,B}
  tree = if metric(ball) isa MinkowskiMetric
    KDTree(coordinates(object), metric(ball))
  else
    BallTree(coordinates(object), metric(ball))
  end
  KBallSearch{O,B,typeof(tree)}(object, k, ball, tree)
end

maxneighbors(method::KBallSearch) = method.k

function search!(neighbors, xₒ::AbstractVector,
                 method::KBallSearch; mask=nothing)
  k = method.k
  r = radius(method.ball)

  inds, dists = knn(method.tree, xₒ, k, true)

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

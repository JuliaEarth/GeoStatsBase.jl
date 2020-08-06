# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
#
# Author: @exepulveda
# ------------------------------------------------------------------

"""
    KBallSearcher(object, k, ball; locations)

A method for searching neighbors in spatial `object` inside `neighborhood`.
Used when doing estimation combining k-nearest and radius.
It searches first for the k-nearest by using the internal kdtree and then
limiting the results within the `BallNeighborhood`
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


function KBallSearcher(object::O, k::Int, ball::B; locations=1:npoints(object)) where {O,B}
  @assert 1 ≤ k ≤ length(locations) "number of neighbors must be smaller than number of locations"
  @assert locations ⊆ 1:npoints(object) "invalid locations for spatial object"
  kdtree = KDTree(coordinates(object, locations), metric(ball))
  KBallSearcher{O,B,typeof(kdtree)}(object, k, ball, locations, kdtree)
end

maxneighbors(searcher::KBallSearcher) = searcher.k

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
                 searcher::KBallSearcher; mask=nothing)
  k    = searcher.k
  ball = searcher.ball
  r    = radius(ball)

  inds, dists = knn(searcher.kdtree, xₒ, k, true)
  locs = view(searcher.locations, inds)

  nneigh = 0
  @inbounds for i in 1:length(inds)
    #if mask is true, the locations must be skipped
    useit = (mask === nothing) || !mask[locs[i]]
    if useit && (dists[i] ≤ r)
      nneigh += 1
      neighbors[nneigh] = locs[i]
    end
  end

  nneigh
end
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
struct KBallSearcher{O,K,T,M} <: AbstractBoundedNeighborSearcher

  # input fields
  object::O
  k::Int
  ball::BallNeighborhood{T,M}
  locations::Vector{Int}

  # state fields
  kdtree::K

end


function KBallSearcher(object::O, k::Int, ball::BallNeighborhood{T,M}; locations=1:npoints(object)) where {O,T,M}
  @assert 1 ≤ k ≤ length(locations) "number of neighbors must be smaller than number of locations"
  @assert locations ⊆ 1:npoints(object) "invalid locations for spatial object"
  kdtree = KDTree(coordinates(object, locations), ball.metric)
  KBallSearcher{O,typeof(kdtree),T,M}(object, k, ball, locations, kdtree)
end

maxneighbors(searcher::KBallSearcher) = searcher.nmax

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
                 searcher::KBallSearcher; mask=nothing)

  k      = searcher.k
  ball   = searcher.ball
  radius = ball.radius

  inds, dists = knn(searcher.kdtree, xₒ, k, true)
  locs = view(searcher.locations, inds) #translate from relative indices (inds) to pdomain indices

  if mask ≠ nothing
    nneigh = 0
    @inbounds for i in 1:length(inds)
      #if mask is true, the locations is already
      if mask[locs[i]] && (dists[i] ≤ radius)
        nneigh += 1
        neighbors[nneigh] = locs[i]
      end
    end
  else
    nneigh = 0
    @inbounds for i in 1:length(inds)
      if dists[i] ≤ radius
        nneigh += 1
        neighbors[nneigh] = locs[i]
      end
    end
  end

  nneigh
end
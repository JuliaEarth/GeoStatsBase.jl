# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
KBallSearcher(object, neighborhood)

A method for searching neighbors in spatial `object` inside `neighborhood`.
Used when doing estimation combining k-nearest and radius.
It searches first for the k-nearest by using the internal kdtree and then
limiting the results within the `BallNeighborhood` by calling `isneighbor`
"""
struct KBallSearcher{S<:AbstractNeighborSearcher} <: AbstractBoundedNeighborSearcher
  searcher::S
  nmax::Int
end

object(searcher::KBallSearcher) = object(searcher.searcher)

maxneighbors(searcher::KBallSearcher) = searcher.nmax

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
  searcher::KBallSearcher; mask=nothing)

  knn_searcher = searcher.searcher #internar nearest searcher
  k = searcher.nmax
  neigh = knn_searcher.neigh       #the Ball Neighborhood
  object = knn_searcher.object
  radius = neigh.radius

  inds, dists = knn(knn_searcher.kdtree, xₒ, k, true)

  x = MVector{ndims(object),coordtype(object)}(undef)


  nneigh = 0
  @inbounds for i in 1:k
    loc = inds[i]
    masked = (mask == nothing) || mask[loc]
    if masked 
      coordinates!(x, object, loc)
      if isneighbor(neigh, xₒ, x) #limiting to the radius
        #this may be improve as the knn already returns the distances, but less generic 
        #because the BallNeighborhood can use a different metric indeed
        nneigh += 1
        neighbors[nneigh] = loc
      end
    end
  end

  nneigh
end

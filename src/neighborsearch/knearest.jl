# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KNearestSearcher(object, k; metric=Euclidean())

A method for searching `k` nearest neighbors in spatial `object`
according to `metric`.
"""
struct KNearestSearcher{O,K} <: AbstractBoundedNeighborSearcher
  # input fields
  object::O
  k::Int

  # state fields
  kdtree::K
end

function KNearestSearcher(object::O, k::Int; metric=Euclidean()) where {O}
  kdtree = KDTree(coordinates(object), metric)
  KNearestSearcher{O,typeof(kdtree)}(object, k, kdtree)
end

maxneighbors(searcher::KNearestSearcher) = searcher.k

function search!(neighbors, xₒ::AbstractVector,
                 searcher::KNearestSearcher; mask=nothing)
  k       = searcher.k
  inds, _ = knn(searcher.kdtree, xₒ, k, true)

  if mask ≠ nothing
    nneigh = 0
    @inbounds for i in 1:k
      if mask[inds[i]]
        nneigh += 1
        neighbors[nneigh] = inds[i]
      end
    end
  else
    nneigh = k
    @inbounds for i in 1:k
      neighbors[i] = inds[i]
    end
  end

  nneigh
end
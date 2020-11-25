# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KNearestSearch(object, k; metric=Euclidean())

A method for searching `k` nearest neighbors in spatial `object`
according to `metric`.
"""
struct KNearestSearch{O,K} <: BoundedNeighborSearchMethod
  # input fields
  object::O
  k::Int

  # state fields
  kdtree::K
end

function KNearestSearch(object::O, k::Int; metric=Euclidean()) where {O}
  kdtree = KDTree(coordinates(object), metric)
  KNearestSearch{O,typeof(kdtree)}(object, k, kdtree)
end

maxneighbors(method::KNearestSearch) = method.k

function search!(neighbors, xₒ::AbstractVector,
                 method::KNearestSearch; mask=nothing)
  k       = method.k
  inds, _ = knn(method.kdtree, xₒ, k, true)

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

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BoundedSearcher(searcher, nmax)

A method for searching at most `nmax` neighbors using `searcher`.
"""
struct BoundedSearcher{S<:AbstractNeighborSearcher} <: AbstractBoundedNeighborSearcher
  searcher::S
  nmax::Int
end

object(searcher::BoundedSearcher) = object(searcher.searcher)

maxneighbors(searcher::BoundedSearcher) = searcher.nmax

function search!(neighbors, xₒ::AbstractVector,
                 searcher::BoundedSearcher; mask=nothing)
  inds = search(xₒ, searcher.searcher)
  nmax = searcher.nmax

  nneigh = 0
  @inbounds for ind in inds
    if mask[ind]
      nneigh += 1
      neighbors[nneigh] = ind
    end
    nneigh == nmax && break
  end

  nneigh
end

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

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
                 searcher::BoundedSearcher; mask=nothing)
  locs = search(xₒ, searcher.searcher)
  nmax = searcher.nmax

  nneigh = 0
  @inbounds for loc in locs
    if mask[loc]
      nneigh += 1
      neighbors[nneigh] = loc
    end
    nneigh == nmax && break
  end

  nneigh
end

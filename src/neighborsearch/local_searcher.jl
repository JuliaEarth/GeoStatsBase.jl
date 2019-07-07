# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    LocalNeighborSearcher(neighborhood, nmax)

A search method that finds at most `nmax` neighbors in `neighborhood`.
"""
struct LocalNeighborSearcher{N<:AbstractNeighborhood} <: AbstractNeighborSearcher
  neigh::N
  nmax::Int
end

function search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector{T},
                 searcher::LocalNeighborSearcher; mask=nothing) where {T,N}
  neigh = searcher.neigh
  nmax  = searcher.nmax
  locs  = neigh(xₒ)

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

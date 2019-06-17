# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    LocalNeighborSearcher(domain, K, neighborhood, path)

A search method that finds at most `K` neighbors in
`neighborhood` of `domain` with a search `path`.
"""
mutable struct LocalNeighborSearcher{D<:AbstractDomain,
                                     N<:AbstractNeighborhood,
                                     P<:AbstractPath,
                                     V<:AbstractVector} <: AbstractNeighborSearcher
  domain::D
  K::Int
  neigh::N
  path::P
  buff::V
end

function LocalNeighborSearcher(domain::D, K::Int,
                               neigh::N, path::P) where {D<:AbstractDomain,
                                                         N<:AbstractNeighborhood,
                                                         P<:AbstractPath}
  @assert 1 ≤ K ≤ npoints(domain) "number of neighbors must be smaller than number of locations"

  # pre-allocate memory for coordinates
  buff = MVector{ndims(domain),coordtype(domain)}(undef)

  LocalNeighborSearcher{D,N,P,typeof(buff)}(domain, K, neigh, path, buff)
end

function search!(neighbors::AbstractVector{Int},
                 xₒ::AbstractVector{T},
                 searcher::LocalNeighborSearcher,
                 mask::AbstractVector{Bool}) where {T,N}
  x = searcher.buff
  path = searcher.path

  nneigh = 0
  @inbounds for loc in path
    if mask[loc]
      coordinates!(x, searcher.domain, loc)
      if isneighbor(searcher.neigh, xₒ, x)
        nneigh += 1
        neighbors[nneigh] = loc
      end
    end
    nneigh == searcher.K && break
  end

  nneigh
end

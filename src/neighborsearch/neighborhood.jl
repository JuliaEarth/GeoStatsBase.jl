# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NeighborhoodSearcher(object, neighborhood)

A method for searching neighbors in spatial `object` inside `neighborhood`.
"""
struct NeighborhoodSearcher{O,N,K} <: AbstractNeighborSearcher
  # input fields
  object::O
  neigh::N

  # state fields
  kdtree::K
end

function NeighborhoodSearcher(object::O, neigh::N) where {O,N}
  kdtree = if neigh isa BallNeighborhood
    KDTree(coordinates(object), metric(neigh))
  else
    nothing
  end
  NeighborhoodSearcher{O,N,typeof(kdtree)}(object, neigh, kdtree)
end

# search method for any neighborhood
function search(xₒ::AbstractVector, searcher::NeighborhoodSearcher; mask=nothing)
  object = searcher.object
  neigh  = searcher.neigh
  N = ncoords(object)
  T = coordtype(object)
  n = nelms(object)

  inds = mask ≠ nothing ? view(1:n, mask) : 1:n

  x = MVector{N,T}(undef)

  neighbors = Vector{Int}()
  @inbounds for ind in inds
    coordinates!(x, object, ind)
    if isneighbor(neigh, xₒ, x)
      push!(neighbors, ind)
    end
  end

  neighbors
end

# search method for ball neighborhood
function search(xₒ::AbstractVector, searcher::NeighborhoodSearcher{O,N,K};
                mask=nothing) where {O,N<:BallNeighborhood,K}
  inds = inrange(searcher.kdtree, xₒ, radius(searcher.neigh))
  if mask ≠ nothing
    neighbors = Vector{Int}()
    @inbounds for ind in inds
      if mask[ind]
        push!(neighbors, ind)
      end
    end
    neighbors
  else
    inds
  end
end

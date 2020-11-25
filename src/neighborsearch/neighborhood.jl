# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NeighborhoodSearch(object, neighborhood)

A method for searching neighbors in spatial `object` inside `neighborhood`.
"""
struct NeighborhoodSearch{O,N,K} <: NeighborSearchMethod
  # input fields
  object::O
  neigh::N

  # state fields
  kdtree::K
end

function NeighborhoodSearch(object::O, neigh::N) where {O,N}
  kdtree = if neigh isa BallNeighborhood
    KDTree(coordinates(object), metric(neigh))
  else
    nothing
  end
  NeighborhoodSearch{O,N,typeof(kdtree)}(object, neigh, kdtree)
end

# search method for any neighborhood
function search(xₒ::AbstractVector, method::NeighborhoodSearch; mask=nothing)
  object = method.object
  neigh  = method.neigh
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
function search(xₒ::AbstractVector, method::NeighborhoodSearch{O,N,K};
                mask=nothing) where {O,N<:BallNeighborhood,K}
  inds = inrange(method.kdtree, xₒ, radius(method.neigh))
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

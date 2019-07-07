# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    NeighborhoodSearcher(object, neighborhood)

A method for searching neighbors in spatial `object` inside `neighborhood`.
"""
struct NeighborhoodSearcher{O<:AbstractSpatialObject,
                            N<:AbstractNeighborhood,T} <: AbstractNeighborSearcher
  # input fields
  object::O
  neigh::N

  # state fields
  kdtree::T
end

function NeighborhoodSearcher(object::O, neigh::N) where {O,N}
  kdtree = neigh isa BallNeighborhood ? KDTree(coordinates(object), metric(neigh)) : nothing
  NeighborhoodSearcher{O,N,typeof(kdtree)}(object, neigh, kdtree)
end

# search method for any neighborhood
function search(xₒ::AbstractVector, searcher::NeighborhoodSearcher{O,N,T};
                mask=nothing) where {O,N,T}
  object = searcher.object
  neigh  = searcher.neigh
  locs   = mask ≠ nothing ? view(1:npoints(object), mask) : 1:npoints(object)

  x = MVector{ndims(object),coordtype(object)}(undef)

  neighbors = Vector{Int}()
  @inbounds for loc in locs
    coordinates!(x, object, loc)
    if isneighbor(neigh, xₒ, x)
      push!(neighbors, loc)
    end
  end

  neighbors
end

# search method for ball neighborhood
function search(xₒ::AbstractVector, searcher::NeighborhoodSearcher{O,N,T};
                mask=nothing) where {O,N<:BallNeighborhood,T}
  locs = inrange(searcher.kdtree, xₒ, radius(searcher.neigh), true)
  if mask ≠ nothing
    neighbors = Vector{Int}()
    @inbounds for loc in locs
      if mask[loc]
        push!(neighbors, loc)
      end
    end
    neighbors
  else
    locs
  end
end

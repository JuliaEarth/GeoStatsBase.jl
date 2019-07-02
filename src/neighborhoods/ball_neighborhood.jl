# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    BallNeighborhood(object, radius)

A ball neighborhood of a given `radius` on a spatial `object`.
"""
struct BallNeighborhood{T,N,O<:AbstractSpatialObject{T,N},M<:Metric} <: AbstractNeighborhood{O}
  # input fields
  object::O
  radius::T
  metric::M

  # state fields
  kdtree::KDTree

  function BallNeighborhood{T,N,O,M}(object, radius, metric) where {T,N,
                                                                    O<:AbstractSpatialObject{T,N},
                                                                    M<:Metric}
    @assert radius > 0 "radius must be positive"
    kdtree = KDTree(coordinates(object), metric)
    new(object, radius, metric, kdtree)
  end
end

BallNeighborhood(object::O, radius::T, metric::M=Euclidean()) where {T,N,
                                                                     O<:AbstractSpatialObject{T,N},
                                                                     M<:Metric} =
  BallNeighborhood{T,N,O,M}(object, radius, metric)

function (neigh::BallNeighborhood)(location::Int)
  neigh(coordinates(neigh.object, location))
end

function (neigh::BallNeighborhood)(xₒ::AbstractVector)
  inrange(neigh.kdtree, xₒ, neigh.radius, true)
end

function isneighbor(neigh::BallNeighborhood, xₒ::AbstractVector, x::AbstractVector)
  evaluate(neigh.metric, xₒ, x) ≤ neigh.radius
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, neigh::BallNeighborhood)
  r = neigh.radius
  print(io, "BallNeighborhood($r)")
end

function Base.show(io::IO, ::MIME"text/plain", neigh::BallNeighborhood)
  println(io, "BallNeighborhood")
  println(io, "  radius: ", neigh.radius)
  println(io, "  metric: ", neigh.metric)
end

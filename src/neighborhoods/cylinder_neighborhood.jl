# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    CylinderNeighborhood(domain, radius, height)

A cylinder neighborhood with a given `radius` and `height` on a spatial `domain`.

### Notes

The `height` parameter is only half of the actual cylinder height.
"""
struct CylinderNeighborhood{T,N,D<:AbstractDomain{T,N}} <: AbstractNeighborhood{D}
  domain::D
  radius::T
  height::T

  function CylinderNeighborhood{T,N,D}(domain, radius, height) where {T,N,D<:AbstractDomain}
    @assert radius > 0 "cylinder radius must be positive"
    @assert height > 0 "cylinder height must be positive"
    new(domain, radius, height)
  end
end

CylinderNeighborhood(domain::D, radius::T, height::T) where {T,N,D<:AbstractDomain{T,N}} =
  CylinderNeighborhood{T,N,D}(domain, radius, height)

function (neigh::CylinderNeighborhood)(location::Int)
  neigh(coordinates(neigh.domain, location))
end

function (neigh::CylinderNeighborhood)(xₒ::AbstractVector)
  # retrieve domain
  ndomain = neigh.domain

  # neighborhood specs
  r = neigh.radius
  h = neigh.height

  # pre-allocate memory for neighbors coordinates
  x = MVector{ndims(ndomain),coordtype(ndomain)}(undef)

  neighbors = Vector{Int}()
  for loc in 1:npoints(ndomain)
    coordinates!(x, ndomain, loc)

    if isneighbor(neigh, xₒ, x)
      push!(neighbors, loc)
    end
  end

  neighbors
end

function isneighbor(neigh::CylinderNeighborhood, xₒ::AbstractVector, x::AbstractVector)
  l = length(xₒ)
  @inbounds abs(x[l] - xₒ[l]) ≤ neigh.height && norm(view(x,1:l-1) .- view(xₒ,1:l-1)) ≤ neigh.radius
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, neigh::CylinderNeighborhood)
  r = neigh.radius; h = neigh.height
  print(io, "CylinderNeighborhood($r, $h)")
end

function Base.show(io::IO, ::MIME"text/plain", neigh::CylinderNeighborhood)
  println(io, "CylinderNeighborhood")
  println(io, "  radius: ", neigh.radius)
  println(io, "  height: ", neigh.height)
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    CylinderNeighborhood(radius, height)

A cylinder neighborhood with `radius` and `height`.

### Notes

The `height` parameter is only half of the actual cylinder height.
"""
struct CylinderNeighborhood{T} <: AbstractNeighborhood
  radius::T
  height::T

  function CylinderNeighborhood{T}(radius, height) where {T}
    @assert radius > 0 "cylinder radius must be positive"
    @assert height > 0 "cylinder height must be positive"
    new(radius, height)
  end
end

CylinderNeighborhood(radius::T, height::T) where {T} =
  CylinderNeighborhood{T}(radius, height)

"""
    radius(cylinder)

Return the radius of the `cylinder`.
"""
radius(cylinder::CylinderNeighborhood) = cylinder.radius

"""
    height(cylinder)

Return (half of) the height of the `cylinder`.
"""
height(cylinder::CylinderNeighborhood) = cylinder.height

function isneighbor(cylinder::CylinderNeighborhood, xₒ::AbstractVector, x::AbstractVector)
  l = length(xₒ)
  @inbounds abs(x[l] - xₒ[l]) ≤ cylinder.height && norm(view(x,1:l-1) - view(xₒ,1:l-1)) ≤ cylinder.radius
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, cylinder::CylinderNeighborhood)
  r = cylinder.radius; h = cylinder.height
  print(io, "CylinderNeighborhood($r, $h)")
end

function Base.show(io::IO, ::MIME"text/plain", cylinder::CylinderNeighborhood)
  println(io, "CylinderNeighborhood")
  println(io, "  radius: ", cylinder.radius)
  print(  io, "  height: ", cylinder.height)
end

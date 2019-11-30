# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CylinderNeighborhood{N}(radius, height)

A `N`-dimensional cylinder neighborhood with `radius` and `height`.

### Notes

The `height` parameter is only half of the actual cylinder height.
"""
struct CylinderNeighborhood{T,N} <: AbstractNeighborhood{T,N}
  radius::T
  height::T
end

function CylinderNeighborhood{N}(radius::T, height::T) where {N,T}
  @assert radius > 0 "cylinder radius must be positive"
  @assert height > 0 "cylinder height must be positive"
  CylinderNeighborhood{T,N}(radius, height)
end

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
function Base.show(io::IO, cylinder::CylinderNeighborhood{T,N}) where {N,T}
  r = cylinder.radius
  h = cylinder.height
  print(io, "$(N)D CylinderNeighborhood($r, $h)")
end

function Base.show(io::IO, ::MIME"text/plain",
                   cylinder::CylinderNeighborhood{T,N}) where {N,T}
  println(io, "$(N)D CylinderNeighborhood")
  println(io, "  radius: ", cylinder.radius)
  print(  io, "  height: ", cylinder.height)
end

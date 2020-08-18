# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rectangle{T,N}

A rectangle in `N`-dimensional space with coordinates of type `T`.
"""
struct Rectangle{T,N} <: AbstractGeometry{T,N}
  origin::SVector{N,T}
  sides::SVector{N,T}
end

Rectangle(origin::NTuple{N,T}, sides::NTuple{N,T}) where {N,T} =
  Rectangle{T,N}(origin, sides)

Rectangle(origin::MVector{N,T}, sides::MVector{N,T}) where {N,T} =
  Rectangle{T,N}(origin, sides)

in(x, r::Rectangle) = all(r.origin .≤ x .≤ r.origin + r.sides)

"""
    origin(rectangle)

Return the origin (or lower left corner) of the `rectangle`.
"""
origin(r::Rectangle) = r.origin

"""
    sides(rectangle)

Return all the sides of the `rectangle` as a tuple.
"""
sides(r::Rectangle) = r.sides

"""
    center(rectangle)

Return the center of the `rectangle`.
"""
center(r::Rectangle) = @. (r.origin + r.sides / 2)

"""
    diagonal(rectangle)

Return the diagonal of the `rectangle`.
"""
diagonal(r::Rectangle) = sqrt(sum(r.sides.^2))


"""
    volume(rectangle)

Return the volume of the `rectangle`.
"""
volume(r::Rectangle) = prod(r.sides)
# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rectangle(start, finish)

A N-dimensional rectangle with lower left corner at `start`
and upper right corner at `finish`.
"""
struct Rectangle{T,N} <: AbstractGeometry{T,N}
  start::SVector{N,T}
  finish::SVector{N,T}
end

Rectangle(start::NTuple{N,T}, finish::NTuple{N,T}) where {N,T} =
  Rectangle{T,N}(start, finish)

Rectangle(start::Vec{N,T}, finish::Vec{N,T}) where {N,T} =
  Rectangle{T,N}(start, finish)

in(x, r::Rectangle) = all(r.start .≤ x .≤ r.finish)

"""
    extrema(rectangle)

Return the corners of the `rectangle`.
"""
Base.extrema(r::Rectangle) = r.start, r.finish

"""
    sides(rectangle)

Return all the sides of the `rectangle` as a tuple.
"""
sides(r::Rectangle) = r.finish - r.start

"""
    center(rectangle)

Return the center of the `rectangle`.
"""
center(r::Rectangle) = (r.start + r.finish) / 2

"""
    diagonal(rectangle)

Return the diagonal of the `rectangle`.
"""
diagonal(r::Rectangle) = norm(r.finish - r.start)


"""
    volume(rectangle)

Return the volume of the `rectangle`.
"""
volume(r::Rectangle) = prod(r.finish - r.start)
# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Rectangle{T,N}

A rectangle in `N`-dimensional space with coordinates of type `T`.
"""
struct Rectangle{T,N} <: AbstractShape{T,N}
  lowerleft::NTuple{N,T}
  upperright::NTuple{N,T}
end

"""
    center(rectangle)

Return the center of the `rectangle`.
"""
center(r::Rectangle{T,N}) where {N,T} =
  SVector{N,T}([(l+u)/2 for (l,u) in zip(r.lowerleft, r.upperright)])

"""
    diagonal(rectangle)

Return the diagonal of the `rectangle`.
"""
diagonal(r::Rectangle) = norm(u-l for (l,u) in zip(r.lowerleft, r.upperright))


"""
    volume(rectangle)

Return the volume of the `rectangle`.
"""
volume(r::Rectangle) = prod(u-l for (l,u) in zip(r.lowerleft, r.upperright))

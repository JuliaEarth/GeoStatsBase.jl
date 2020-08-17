# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rectangle{T,N}

A rectangle in `N`-dimensional space with coordinates of type `T`.
"""
struct Rectangle{T,N} <: AbstractGeometry{T,N}
  lowerleft::SVector{N,T}
  upperright::SVector{N,T}
end

Rectangle(lowerleft::NTuple{N,T}, upperright::NTuple{N,T}) where {N,T} =
  Rectangle{T,N}(lowerleft, upperright)

Rectangle(lowerleft::MVector{N,T}, upperright::MVector{N,T}) where {N,T} =
  Rectangle{T,N}(lowerleft, upperright)

"""
    center(rectangle)

Return the center of the `rectangle`.
"""
center(r::Rectangle{T,N}) where {N,T} = @. (r.lowerleft + r.upperright) / 2

"""
    lowerleft(rectangle)

Return the lower left corner of the `rectangle`.
"""
lowerleft(r::Rectangle) = r.lowerleft

"""
    upperright(rectangle)

Return the upper right corner of the `rectangle`.
"""
upperright(r::Rectangle) = r.upperright

"""
    side(rectangle, i)

Return the `i`-th side of the `rectangle`.
"""
side(r::Rectangle, i::Int) = r.upperright[i] - r.lowerleft[i]

"""
    sides(rectangle)

Return all the sides of the `rectangle` as a tuple.
"""
sides(r::Rectangle{T,N}) where {N,T} = SVector{N,T}(ntuple(i->side(r, i), N))

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

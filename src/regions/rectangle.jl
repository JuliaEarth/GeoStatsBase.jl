# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RectangleRegion{T,N}

A rectangle region in `N`-dimensional space with coordinates of type `T`.
"""
struct RectangleRegion{T,N} <: AbstractRegion{T,N}
  lowerleft::NTuple{N,T}
  upperright::NTuple{N,T}
end

"""
    center(rectangle)

Return the center of the `rectangle`.
"""
center(r::RectangleRegion{T,N}) where {N,T} =
  SVector{N,T}([(l+u)/2 for (l,u) in zip(r.lowerleft, r.upperright)])

"""
    lowerleft(rectangle)

Return the lower left corner of the `rectangle`.
"""
lowerleft(r::RectangleRegion{T,N}) where {N,T} = SVector{N,T}(r.lowerleft)

"""
    upperright(rectangle)

Return the upper right corner of the `rectangle`.
"""
upperright(r::RectangleRegion{T,N}) where {N,T} = SVector{N,T}(r.upperright)

"""
    side(rectangle, i)

Return the `i`-th side of the `rectangle`.
"""
side(r::RectangleRegion, i::Int) = r.upperright[i] - r.lowerleft[i]

"""
    sides(rectangle)

Return all the sides of the `rectangle` as a tuple.
"""
sides(r::RectangleRegion{T,N}) where {N,T} = SVector{N,T}(ntuple(i->side(r, i), N))

"""
    diagonal(rectangle)

Return the diagonal of the `rectangle`.
"""
diagonal(r::RectangleRegion) = norm(u-l for (l,u) in zip(r.lowerleft, r.upperright))


"""
    volume(rectangle)

Return the volume of the `rectangle`.
"""
volume(r::RectangleRegion) = prod(u-l for (l,u) in zip(r.lowerleft, r.upperright))

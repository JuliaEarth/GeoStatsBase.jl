# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborhood

A neighborhood of points in a `N`-dimensional space
with coordinates of type `T`.
"""
abstract type AbstractNeighborhood{T,N} end

"""
    ndims(neigh)

Return the number of dimensions of neighborhood `neigh`.
"""
Base.ndims(::AbstractNeighborhood{T,N}) where {N,T} = N

"""
    coordtype(neigh)

Return the coordinate type of neighborhood `neigh`.
"""
coordtype(::AbstractNeighborhood{T,N}) where {N,T} = T

"""
    isneighbor(neigh, xₒ, x)

Tells whether or not the coordinates `x` are in the neighborhood
`neigh` centered at coordinates `xₒ`.
"""
function isneighbor end

"""
    volume(neigh)

Return the volume of neighborhood `neigh`.
"""
function volume end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("neighborhoods/ball.jl")
include("neighborhoods/cylinder.jl")

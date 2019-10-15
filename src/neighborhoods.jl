# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborhood

A neighborhood of points in a spatial object.
"""
abstract type AbstractNeighborhood end

"""
    isneighbor(neighborhood, xₒ, x)

Tells whether or not the coordinates `x` are in the `neighborhood`
centered at coordinates `xₒ`.
"""
isneighbor(neigh::AbstractNeighborhood,
           xₒ::AbstractVector, x::AbstractVector) = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("neighborhoods/ball.jl")
include("neighborhoods/cylinder.jl")

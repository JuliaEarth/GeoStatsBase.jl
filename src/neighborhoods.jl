# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborhood

A neighborhood of points in a spatial object.
"""
abstract type AbstractNeighborhood end

"""
    isneighbor(neigh, xₒ, x)

Tells whether or not the coordinates `x` are in the neighborhood
`neigh` centered at coordinates `xₒ`.
"""
function isneighbor end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("neighborhoods/ball.jl")
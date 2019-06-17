# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborhood{D}

A neighborhood on a spatial domain of type `D`.
"""
abstract type AbstractNeighborhood{D<:AbstractDomain} end

# Neighborhoods are functor objects that can be evaluated
# at a given location:
#
# julia> neighborhood(location)
# julia> neighborhood(xₒ)
#
# The operator () returns the neighbors (as integers).

"""
    isneighbor(neighborhood, center, location)

Tells whether or not the `location` is in the `neighborhood`
centered at `center`.
"""
function isneighbor(neigh::AbstractNeighborhood, center::Int, location::Int)
  xₒ = coordinates(neigh.domain, center)
  x  = coordinates(neigh.domain, location)
  isneighbor(neigh, xₒ, x)
end

"""
    isneighbor(neighborhood, xₒ, x)

Tells whether or not the coordinates `x` is in the `neighborhood`
centered at coordinates `xₒ`.

### Notes

This method is useful in loops, in which case the coordinates
can be pre-allocated for better performance.
"""
isneighbor(neigh::AbstractNeighborhood,
           xₒ::AbstractVector, x::AbstractVector) = error("not implemented")

#------------------
# IMPLEMENTATIONS
#------------------
include("neighborhoods/ball_neighborhood.jl")
include("neighborhoods/cylinder_neighborhood.jl")

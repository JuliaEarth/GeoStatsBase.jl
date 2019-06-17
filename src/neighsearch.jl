# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborSearcher

A method for searching neighbors in a spatial object given a reference point.
"""
abstract type AbstractNeighborSearcher end

"""
    search!(neighbors, xₒ, searcher, mask)

Update `neighbors` of coordinates `xₒ` with the `searcher` and `mask`,
and return number of neighbors found.
"""
search!(::AbstractVector{Int}, ::AbstractVector{T}, ::AbstractNeighborSearcher,
        ::AbstractVector{Bool}) where {T,N} = error("not implemented")

#------------------
# IMPLEMENTATIONS
#------------------
include("neighsearch/nearest.jl")
include("neighsearch/local.jl")

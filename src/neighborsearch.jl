# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborSearcher

A method for searching neighbors in a spatial object given a reference point.
"""
abstract type AbstractNeighborSearcher end

"""
    search(xₒ, searcher, mask=nothing)

Return neighbors of coordinates `xₒ` with the `searcher` and `mask`.
"""
search(xₒ::AbstractVector, searcher::AbstractNeighborSearcher;
       mask=nothing) = error("not implemented")

"""
    AbstractBoundedNeighborSearcher

A method for searching neighbors with the property that the number of neighbors
is bounded above by a known constant (e.g. k-nearest neighbors).
"""
abstract type AbstractBoundedNeighborSearcher <: AbstractNeighborSearcher end

"""
    maxneighbors(searcher)

Return the maximum number of neighbors obtained with `searcher`.
"""
maxneighbors(searcher::AbstractBoundedNeighborSearcher) = error("not implemented")

"""
    search!(neighbors, xₒ, searcher, mask)

Update `neighbors` of coordinates `xₒ` with the `searcher` and `mask`,
and return number of neighbors found.
"""
search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
        searcher::AbstractBoundedNeighborSearcher;
        mask=nothing) = error("not implemented")

function search(xₒ::AbstractVector, searcher::AbstractBoundedNeighborSearcher; mask=nothing)
  neighbors = Vector{Int}(undef, maxneighbors(searcher))
  nneigh = search!(neighbors, xₒ, searcher; mask=mask)
  view(neighbors, 1:nneigh)
end

#------------------
# IMPLEMENTATIONS
#------------------
include("neighborsearch/nearest_searcher.jl")
include("neighborsearch/neighborhood_searcher.jl")
include("neighborsearch/bounded_searcher.jl")

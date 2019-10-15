# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractNeighborSearcher

A method for searching neighbors in a spatial object given a reference point.
"""
abstract type AbstractNeighborSearcher end

"""
    object(searcher)

Return the spatial object containing all possible neighbors.
"""
object(searcher::AbstractNeighborSearcher) = searcher.object

"""
    search(xₒ, searcher, mask=nothing)

Return neighbors of coordinates `xₒ` using `searcher` and a `mask` over
the spatial object.
"""
search(xₒ::AbstractVector, searcher::AbstractNeighborSearcher;
       mask=nothing) = @error "not implemented"

"""
    search(location, searcher, mask=nothing)

Return neighbors of `location` in spatial object using `searcher` and a `mask`.
"""
search(location::Int, searcher::AbstractNeighborSearcher; mask=nothing) =
  search(coordinates(object(searcher), location), searcher; mask=mask)

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
maxneighbors(searcher::AbstractBoundedNeighborSearcher) = @error "not implemented"

"""
    search!(neighbors, xₒ, searcher, mask)

Update `neighbors` of coordinates `xₒ` using `searcher` and `mask`,
and return number of neighbors found.
"""
search!(neighbors::AbstractVector{Int}, xₒ::AbstractVector,
        searcher::AbstractBoundedNeighborSearcher;
        mask=nothing) = @error "not implemented"

"""
    search!(neighbors, location, searcher, mask)

Update `neighbors` of `location` in spatial object using `searcher` and `mask`,
and return number of neighbors found.
"""
search!(neighbors::AbstractVector{Int}, location::Int,
        searcher::AbstractBoundedNeighborSearcher; mask=nothing) =
  search!(neighbors, coordinates(object(searcher), location), searcher; mask=mask)

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

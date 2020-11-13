# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
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
function search end

"""
    search(ind, searcher, mask=nothing)

Return neighbors of index `ind` in spatial object using `searcher` and a `mask`.
"""
search(ind::Int, searcher::AbstractNeighborSearcher; mask=nothing) =
  search(coordinates(object(searcher), ind), searcher; mask=mask)

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
function maxneighbors end

"""
    search!(neighbors, xₒ, searcher, mask)

Update `neighbors` of coordinates `xₒ` using `searcher` and `mask`,
and return number of neighbors found.
"""
function search! end

"""
    search!(neighbors, ind, searcher, mask)

Update `neighbors` of index `ind` in spatial object using `searcher` and `mask`,
and return number of neighbors found.
"""
search!(neighbors, ind::Int, searcher::AbstractBoundedNeighborSearcher; mask=nothing) =
  search!(neighbors, coordinates(object(searcher), ind), searcher; mask=mask)

function search(xₒ::AbstractVector, searcher::AbstractBoundedNeighborSearcher; mask=nothing)
  neighbors = Vector{Int}(undef, maxneighbors(searcher))
  nneigh = search!(neighbors, xₒ, searcher; mask=mask)
  view(neighbors, 1:nneigh)
end

#------------------
# IMPLEMENTATIONS
#------------------
include("neighborsearch/neighborhood.jl")
include("neighborsearch/knearest.jl")
include("neighborsearch/kball.jl")
include("neighborsearch/bounded.jl")

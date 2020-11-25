# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NeighborSearchMethod

A method for searching neighbors in a spatial object given a reference point.
"""
abstract type NeighborSearchMethod end

"""
    object(method)

Return the spatial object containing all possible neighbors.
"""
object(method::NeighborSearchMethod) = method.object

"""
    search(xₒ, method, mask=nothing)

Return neighbors of coordinates `xₒ` using `method` and a `mask` over
the spatial object.
"""
function search end

"""
    search(ind, method, mask=nothing)

Return neighbors of index `ind` in spatial object using `method` and a `mask`.
"""
search(ind::Int, method::NeighborSearchMethod; mask=nothing) =
  search(coordinates(object(method), ind), method; mask=mask)

"""
    BoundedNeighborSearchMethod

A method for searching neighbors with the property that the number of neighbors
is bounded above by a known constant (e.g. k-nearest neighbors).
"""
abstract type BoundedNeighborSearchMethod <: NeighborSearchMethod end

"""
    maxneighbors(method)

Return the maximum number of neighbors obtained with `method`.
"""
function maxneighbors end

"""
    search!(neighbors, xₒ, method, mask)

Update `neighbors` of coordinates `xₒ` using `method` and `mask`,
and return number of neighbors found.
"""
function search! end

"""
    search!(neighbors, ind, method, mask)

Update `neighbors` of index `ind` in spatial object using `method` and `mask`,
and return number of neighbors found.
"""
search!(neighbors, ind::Int, method::BoundedNeighborSearchMethod; mask=nothing) =
  search!(neighbors, coordinates(object(method), ind), method; mask=mask)

function search(xₒ::AbstractVector, method::BoundedNeighborSearchMethod; mask=nothing)
  neighbors = Vector{Int}(undef, maxneighbors(method))
  nneigh = search!(neighbors, xₒ, method; mask=mask)
  view(neighbors, 1:nneigh)
end

#------------------
# IMPLEMENTATIONS
#------------------
include("neighborsearch/neighborhood.jl")
include("neighborsearch/knearest.jl")
include("neighborsearch/kball.jl")
include("neighborsearch/bounded.jl")

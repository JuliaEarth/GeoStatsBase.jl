# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StructuredGrid(X, Y, Z, ...)

A structured grid with coordinates `X`, `Y`, `Z`, ...

## Examples

A 2D structured grid can be constructed from coordinates stored in
2D matrices. For example, we can georeference locations in the Earth
surface using `LAT` and `LON` coordinates:

```julia
julia> StructuredGrid(LAT, LON)
```
"""
struct StructuredGrid{T,N} <: AbstractDomain{T,N}
  coords::Matrix{T}
  dims::Dims{N}
end

function StructuredGrid(coordarrays::Vararg{<:AbstractArray{T},N}) where {N,T}
  sizes = [size(array) for array in coordarrays]
  @assert length(unique(sizes)) == 1 "coordinates arrays must have the same dimensions"

  coords = Matrix{T}(undef, N, prod(sizes[1]))
  for (i, array) in enumerate(coordarrays)
    coords[i,:] = array
  end

  StructuredGrid{T,N}(coords, sizes[1])
end

Base.size(grid::StructuredGrid) = grid.dims

npoints(grid::StructuredGrid) = prod(grid.dims)

function coordinates!(buff::AbstractVector{T}, grid::StructuredGrid{T,N},
                      location::Int) where {N,T}
  buff .= grid.coords[:,location]
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, grid::StructuredGrid{T,N}) where {N,T}
  dims = join(grid.dims, "×")
  print(io, "$dims StructuredGrid{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", grid::StructuredGrid{T,N}) where {N,T}
  println(io, grid)
  Base.print_array(io, grid.coords)
end

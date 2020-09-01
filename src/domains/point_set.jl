# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PointSet(coords)

A set of points with coordinates vector `coords`. The vector
contains many coordinates (number of points), where each coordinate
is implemented by a static array of length same as the dimensionality.
To build the PointSet a Matrix can be use. The matrix is the dimensionality 
of the domain whereas the number of columns is the number of points in the set
or a Vector of tuples that will be converted to a Vector of static array.

## Examples

Create a 2D point set with 100 points:

```julia
julia> PointSet(rand(2,100))
```

Or equivalently, using a vector of tuples:

```julia
julia> PointSet([(rand(),rand()) for i in 1:100])
```
"""
struct PointSet{T,N} <: SpatialDomain{T,N}
  coords::Vector{SVector{N,T}} 

  function PointSet{T,N}(coords) where {N,T}
    @assert !isempty(coords) "coordinates must be non-empty"
    new(coords)
  end
end

function PointSet(coords::AbstractMatrix{T}) where {T}
  N = size(coords, 1)
  points = Vector{SVector{N,T}}()
  for row in eachcol(coords)
    push!(points,SVector{N,T}(row))
  end
  PointSet{T,N}(points)
end

function PointSet(coords::AbstractVector{NTuple{N,T}}) where {N,T}
  points = Vector{SVector{N,T}}()
  for row in coords
    push!(points,SVector{N,T}(row))
  end
  PointSet{T,N}(points)
end

nelms(ps::PointSet) = size(ps.coords,1)

function coordinates!(buff::AbstractVector{T}, ps::PointSet{T,N},
                      location::Int) where {N,T}
  @inbounds for i in 1:N
    buff[i] = ps.coords[location][i]
  end
end
# ------------
# IO methods
# ------------
function Base.show(io::IO, ps::PointSet{T,N}) where {N,T}
  npts = nelms(ps)
  print(io, "$npts PointSet{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", ps::PointSet{T,N}) where {N,T}
  println(io, ps)
  Base.print_array(io, ps.coords)
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RegularGrid(dims, origin, spacing)

A regular grid with dimensions `dims`, lower left corner at `origin`
and cell spacing `spacing`. The three arguments must have the same length.

    RegularGrid(start, finish, dims=dims)

Alternatively, construct a regular grid from a `start` point (lower left)
to a `finish` point (upper right).

    RegularGrid{T}(dims)
    RegularGrid{T}(dim1, dim2, ...)

Finally, a regular grid can be constructed by only passing the dimensions
`dims` as a tuple, or by passing each dimension `dim1`, `dim2`, ... separately.
In this case, the origin and spacing default to (0,0,...) and (1,1,...).

## Examples

Create a 3D grid with 100x100x50 locations:

```julia
julia> RegularGrid(100,100,50)
```

Create a 2D grid with 100x100 locations and origin at (10.,20.) units:

```julia
julia> RegularGrid((100,100),(10.,20.),(1.,1.))
```

Create a 1D grid from -1 to 1 with 100 locations:

```julia
julia> RegularGrid((-1.,),(1.,), dims=(100,))
```
"""
struct RegularGrid{T,N} <: AbstractDomain{T,N}
  dims::Dims{N}
  origin::SVector{N,T}
  spacing::SVector{N,T}

  function RegularGrid{T,N}(dims, origin, spacing) where {N,T}
    @assert all(dims .> 0) "dimensions must be positive"
    @assert all(spacing .> 0) "spacing must be positive"
    new(dims, origin, spacing)
  end
end

RegularGrid(dims::Dims{N}, origin::Vec{N,T}, spacing::Vec{N,T}) where {N,T} =
  RegularGrid{T,N}(dims, origin, spacing)

RegularGrid(dims::Dims{N}, origin::NTuple{N,T}, spacing::NTuple{N,T}) where {N,T} =
  RegularGrid{T,N}(dims, origin, spacing)

RegularGrid(start::Vec{N,T}, finish::Vec{N,T};
            dims::Dims{N}=ntuple(i->100, N)) where {N,T} =
  RegularGrid{T,N}(dims, start, @. (finish - start) / (dims - 1))

RegularGrid(start::NTuple{N,T}, finish::NTuple{N,T};
            dims::Dims{N}=ntuple(i->100, N)) where {N,T} =
  RegularGrid(SVector(start), SVector(finish); dims=dims)

RegularGrid{T}(dims::Dims{N}) where {N,T} =
  RegularGrid{T,N}(dims, ntuple(i->zero(T), N), ntuple(i->one(T), N))

RegularGrid{T}(dims::Vararg{Int,N}) where {N,T} = RegularGrid{T}(dims)

RegularGrid(dims::Dims{N}) where {N} = RegularGrid{Float64}(dims)

RegularGrid(dims::Vararg{Int,N}) where {N} = RegularGrid{Float64}(dims)

Base.size(grid::RegularGrid) = grid.dims
origin(grid::RegularGrid)    = grid.origin
spacing(grid::RegularGrid)   = grid.spacing

npoints(grid::RegularGrid) = prod(grid.dims)

function coordinates!(buff::AbstractVector{T}, grid::RegularGrid{T,N},
                      location::Int) where {N,T}
  intcoords = CartesianIndices(grid.dims)[location]
  @inbounds @simd for i in 1:N
    buff[i] = grid.origin[i] + (intcoords[i] - 1)*grid.spacing[i]
  end
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, grid::RegularGrid{T,N}) where {N,T}
  dims = join(grid.dims, "×")
  print(io, "$dims RegularGrid{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", grid::RegularGrid{T,N}) where {N,T}
  println(io, grid)
  println(io, "  origin:  ", Tuple(grid.origin))
  print(  io, "  spacing: ", Tuple(grid.spacing))
end

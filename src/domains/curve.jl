# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Curve(x, y, z, ...)

A curve along parametric coordinates `x`, `y`, `z`, ...

    Curve(coords)

Alternatively, construct curve from `coords` matrix. The number of rows
of the matrix is the dimensionality of the curve whereas the number
of columns is the number of points.

## Examples

A 3D borehole or directional well can be represented with a curve
where `x`, `y`, and `z` are the parametric coordinates `(x(t), y(t), z(t))`
with parameter `t ∈ R`:

```julia
julia> Curve(x, y, z)
```
"""
struct Curve{T,N} <: AbstractDomain{T,N}
  coords::Matrix{T}
end

function Curve(coordarrays::Vararg{<:AbstractVector{T},N}) where {N,T}
  npts = length.(coordarrays)
  @assert length(unique(npts)) == 1 "coordinates arrays must have the same dimensions"

  coords = Matrix{T}(undef, N, npts[1])
  for (i, array) in enumerate(coordarrays)
    coords[i,:] = array
  end

  Curve{T,N}(coords)
end

Curve(coords::AbstractMatrix{T}) where {T} = Curve{T,size(coords,1)}(coords)

npoints(curve::Curve) = size(curve.coords, 2)

function coordinates!(buff::AbstractVector{T}, curve::Curve{T,N},
                      location::Int) where {N,T}
  for i in 1:N
    @inbounds buff[i] = curve.coords[i,location]
  end
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, curve::Curve{T,N}) where {N,T}
  npts = size(curve.coords, 2)
  print(io, "$npts Curve{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", curve::Curve{T,N}) where {N,T}
  println(io, curve)
  Base.print_array(io, curve.coords)
end

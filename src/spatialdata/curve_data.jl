# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    CurveData(data, x, y, z, ...)

Spatial `data` georeferenced with parametric coordinates `x`, `y`, `z`, ...
The `data` argument is a dictionary mapping variable names to Julia arrays
with the actual data.

See also: [`Curve`](@ref)
"""
struct CurveData{T,N} <: AbstractData{T,N}
  data::Dict{Symbol,<:AbstractArray}
  domain::Curve{T,N}

  function CurveData{T,N}(data, domain) where {N,T}
    nvals = [length(array) for array in values(data)]
    @assert all(nvals .== npoints(domain)) "data and domain must have the same number of points"
    new(data, domain)
  end
end

CurveData(data::Dict{Symbol,<:AbstractArray},
          coords::AbstractMatrix{T}) where {T} =
  CurveData{T,size(coords,1)}(data, Curve(coords))

CurveData(data::Dict{Symbol,<:AbstractArray},
          coordarrays::Vararg{<:AbstractVector{T},N}) where {N,T} =
  CurveData{T,N}(data, Curve(coordarrays...))

# ------------
# IO methods
# ------------
function Base.show(io::IO, geodata::CurveData{T,N}) where {N,T}
  npts = npoints(geodata)
  print(io, "$npts CurveData{$T,$N}")
end

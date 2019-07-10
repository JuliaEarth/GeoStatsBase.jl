# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    StructuredGridData(data, X, Y, Z, ...)

Data spatially distributed on a structured grid where points are
georeferenced by coordinates `X`, `Y`, `Z`, ...

The `data` argument is a dictionary mapping variable names to Julia
arrays with the actual data.

## Examples

A very popular structured grid data format is NetCDF. Given 2D arrays
`LAT` and `LON` with coordinates and arrays with climate data `precipitation`,
`temperature`, the following code can be used to construct a structured grid:

```julia
julia> data = Dict(:precipitation => precipitation, :temperature => temperature)
julia> StructuredGridData(data, LAT, LON)
```

See also: [`StructuredGrid`](@ref)
"""
struct StructuredGridData{T,N} <: AbstractData{T,N}
  data::Dict{Symbol,<:AbstractArray}
  domain::StructuredGrid{T,N}

  function StructuredGridData{T,N}(data, domain) where {N,T}
    sizes = [size(array) for array in values(data)]
    @assert length(unique(sizes)) == 1 "data dimensions must be the same for all variables"
    @assert prod(sizes[1]) == npoints(domain) "data and coordinates arrays must have the same number of indices"
    new(data, domain)
  end
end

StructuredGridData(data::Dict{Symbol,<:AbstractArray},
                   coordarrays::Vararg{<:AbstractArray{T},N}) where {N,T} =
  StructuredGridData{T,N}(data, StructuredGrid(coordarrays...))

Base.size(geodata::StructuredGridData) = size(geodata.domain)

Base.getindex(geodata::StructuredGridData, var::Symbol) =
  reshape(values(geodata, var), size(geodata))

function Base.getindex(geodata::StructuredGridData,
                       icoords::Vararg{Int,N}) where {N}
  vars = [var for (var,V) in variables(geodata)]
  vals = [geodata.data[var][icoords...] for var in vars]
  NamedTuple{tuple(vars...)}(vals)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, geodata::StructuredGridData{T,N}) where {N,T}
  dims = join(size(geodata), "×")
  print(io, "$dims StructuredGridData{$T,$N}")
end

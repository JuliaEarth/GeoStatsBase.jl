# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeoDataFrame(data, coordnames)

A dataframe object `data` with additional metadata for tracking
the columns `coordnames` that represent spatial coordinates.

## Examples

If the data was already loaded in a normal DataFrame `data`,
and there exists columns named `x`, `y` and `z`, wrap the
data and specify the column names:

```julia
julia> GeoDataFrame(data, [:x,:y,:z])
```

Alternatively, load the data directly into a `GeoDataFrame` object
by using the method [`readgeotable`](@ref).

### Notes

This type is a lightweight wrapper over Julia's DataFrame types.
No additional storage is required other than a vector of symbols
with the columns names representing spatial coordinates.

"""
struct GeoDataFrame{T,N,DF<:AbstractDataFrame} <: AbstractData{T,N}
  data::DF
  coordnames::Vector{Symbol}

  function GeoDataFrame{T,N,DF}(data, coordnames) where {T,N,DF<:AbstractDataFrame}
    new(data, coordnames)
  end
end

function GeoDataFrame(data::DF, coordnames::AbstractVector{Symbol}) where {DF<:AbstractDataFrame}
  @assert coordnames ⊆ names(data) "invalid column names"

  Ts = [eltype(data[!,c]) for c in coordnames]
  T  = promote_type(Ts...)
  N  = length(coordnames)

  @assert !(Missing <: T) "coordinates cannot be missing"

  GeoDataFrame{T,N,DF}(data, coordnames)
end

domain(geodata::GeoDataFrame) = PointSet(coordinates(geodata))

coordnames(geodata::GeoDataFrame) = Tuple(geodata.coordnames)

function variables(geodata::GeoDataFrame)
  data   = geodata.data
  cnames = geodata.coordnames
  vnames = [var for var in names(data) if var ∉ cnames]
  vtypes = [eltype(data[!,var]) for var in vnames]

  OrderedDict(var => T for (var,T) in zip(vnames,vtypes))
end

npoints(geodata::GeoDataFrame) = nrow(geodata.data)

function coordinates!(buff::AbstractVector, geodata::GeoDataFrame, ind::Int)
  data   = geodata.data
  cnames = geodata.coordnames

  for (i, cname) in enumerate(cnames)
    @inbounds buff[i] = data[ind,cname]
  end
end

# specialize methods from spatial data
Base.getindex(geodata::GeoDataFrame, ind::Int, var::Symbol) =
  getindex(geodata.data, ind, var)

# ------------
# IO methods
# ------------
function Base.show(io::IO, geodata::GeoDataFrame)
  dims = join(size(geodata.data), "×")
  cnames = join(geodata.coordnames, ", ", " and ")
  print(io, "$dims GeoDataFrame ($cnames)")
end

function Base.show(io::IO, ::MIME"text/plain", geodata::GeoDataFrame)
  println(io, geodata)
  show(io, geodata.data, allcols=true, summary=false)
end

function Base.show(io::IO, ::MIME"text/html", geodata::GeoDataFrame)
  println(io, geodata)
  show(io, MIME"text/html"(), geodata.data, summary=false)
end

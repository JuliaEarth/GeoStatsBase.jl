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
  @assert coordnames ⊆ names(data) "coordnames must contain valid column names"

  Ts = Base.nonmissingtype.(eltypes(data[coordnames]))
  T  = promote_type(Ts...)
  N  = length(coordnames)

  GeoDataFrame{T,N,DF}(data, coordnames)
end

domain(geodata::GeoDataFrame) = PointSet(coordinates(geodata))

function coordnames(geodata::GeoDataFrame)
  rawdata = geodata.data
  cnames = geodata.coordnames

  Tuple(cnames)
end

function variables(geodata::GeoDataFrame)
  rawdata = geodata.data
  cnames = geodata.coordnames
  vnames = [var for var in names(rawdata) if var ∉ cnames]
  vtypes = Base.nonmissingtype.(eltypes(rawdata[vnames]))

  Dict(var => T for (var,T) in zip(vnames,vtypes))
end

npoints(geodata::GeoDataFrame) = nrow(geodata.data)

function coordinates!(buff::AbstractVector, geodata::GeoDataFrame, ind::Int)
  rawdata = geodata.data
  cnames = geodata.coordnames

  for (i, cname) in enumerate(cnames)
    @inbounds buff[i] = rawdata[ind,cname]
  end
end

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

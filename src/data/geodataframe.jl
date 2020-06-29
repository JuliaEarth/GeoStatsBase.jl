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
struct GeoDataFrame{T,N,𝒯} <: AbstractData{T,N}
  data::𝒯
  coordnames::Vector{Symbol}

  function GeoDataFrame{T,N,𝒯}(data, coordnames) where {T,N,𝒯}
    new(data, coordnames)
  end
end

function GeoDataFrame(data::𝒯, coordnames::AbstractVector{Symbol}) where {𝒯}
  @assert coordnames ⊆ propertynames(data) "invalid column names"

  Ts = [eltype(data[!,c]) for c in coordnames]
  T  = promote_type(Ts...)
  N  = length(coordnames)

  @assert !(Missing <: T) "coordinates cannot be missing"

  GeoDataFrame{T,N,𝒯}(data, coordnames)
end

domain(sdata::GeoDataFrame) = PointSet(coordinates(sdata))

coordnames(sdata::GeoDataFrame) = Tuple(sdata.coordnames)

function variables(sdata::GeoDataFrame)
  c = sdata.coordnames
  s = Tables.schema(sdata.data)
  n, t = s.names, s.types
  nt = (; [(var,V) for (var,V) in zip(n,t) if var ∉ c]...)
  Variables{typeof(nt)}(nt)
end

npoints(sdata::GeoDataFrame) = size(sdata.data, 1)

function coordinates!(buff::AbstractVector, sdata::GeoDataFrame, ind::Int)
  data   = sdata.data
  cnames = sdata.coordnames

  @inbounds for (i, cname) in enumerate(cnames)
    buff[i] = data[ind,cname]
  end
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, sdata::GeoDataFrame)
  dims = join(size(sdata.data), "×")
  cnames = join(sdata.coordnames, ", ", " and ")
  print(io, "$dims GeoDataFrame ($cnames)")
end

function Base.show(io::IO, ::MIME"text/plain", sdata::GeoDataFrame)
  println(io, sdata)
  show(io, sdata.data, allcols=true, summary=false)
end

function Base.show(io::IO, ::MIME"text/html", sdata::GeoDataFrame)
  println(io, sdata)
  show(io, MIME"text/html"(), sdata.data, summary=false)
end

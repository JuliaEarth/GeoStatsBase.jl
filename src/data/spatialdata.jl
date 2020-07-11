# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialData(domain, data)

Tabular `data` georeferenced in a spatial `domain`.
"""
struct SpatialData{T,N,𝒟,𝒯} <: AbstractData{T,N}
  domain::𝒟
  table::𝒯
end

function SpatialData(domain, table)
  T = coordtype(domain)
  N = ndims(domain)
  𝒟 = typeof(domain)
  𝒯 = typeof(table)
  SpatialData{T,N,𝒟,𝒯}(domain, table)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, sdata::SpatialData{T,N,𝒟,𝒯}) where {T,N,𝒟,𝒯}
  npts = npoints(sdata.domain)
  print(io, "$npts SpatialData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", sdata::SpatialData{T,N,𝒟,𝒯}) where {N,T,𝒟,𝒯}
  println(io, sdata)
  println(io, "  variables")
  varlines = ["    └─$var ($V)" for (var,V) in variables(sdata)]
  print(io, join(varlines, "\n"))
end

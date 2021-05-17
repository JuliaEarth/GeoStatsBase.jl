# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeoData(domain, data)

Tabular `data` georeferenced on a given spatial `domain`.

### Notes

This type implements the [`Data`](@ref) interface from
[Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl).
"""
struct GeoData{𝒟,𝒯} <: Meshes.Data
  domain::𝒟
  table::𝒯

  function GeoData{𝒟,𝒯}(domain, table) where {𝒟,𝒯}
    ne = nelements(domain)
    nr = length(Tables.rows(table))
    @assert ne == nr "number of table rows ≠ number of mesh elements"
    new(domain, table)
  end
end

GeoData(domain::𝒟, table::𝒯) where {𝒟,𝒯} =
  GeoData{𝒟,𝒯}(domain, table)

# ---------------
# DATA INTERFACE
# ---------------

Meshes.domain(data::GeoData) = getfield(data, :domain)
Meshes.values(data::GeoData) = getfield(data, :table)
Meshes.constructor(::Type{D}) where {D<:GeoData} = GeoData

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeoCollection

An indexable collection of georeferenced elements.
"""
abstract type GeoCollection end

"""
    GeoDomain

A [`GeoCollection`](@ref) that represents geospatial domains.

## Traits

* [`npoints`](@ref)     - number of elements
* [`ncoords`](@ref)     - number of coordinates
* [`coordtype`](@ref)   - coordinate type
* [`coordinate!`](@ref) - coordinates
"""
struct GeoDomain <: GeoCollection end

"""
    GeoData

A [`GeoCollection`](@ref) that represents geospatial data, i.e.
a geospatial `domain` together with a data table of `values`.

## Traits

* [`domain`](@ref)      - spatial domain
* [`values`](@ref)      - data table
"""
struct GeoData <: GeoCollection end

"""
    geotype(object)

Return the geospatial type of the `object`.
"""
geotype

# required traits for each geotype
include("geotraits/domain.jl")
include("geotraits/data.jl")

# fallback implementations
include("geotraits/fallback.jl")
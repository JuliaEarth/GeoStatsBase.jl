# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniformWeighting()

A weighting method that assigns uniform weights to points in spatial object.
"""
struct UniformWeighting <: WeightingMethod end

weight(object, method::UniformWeighting) = weight(domain(object), method)

weight(domain::Domain, ::UniformWeighting) = GeoWeights(domain, ones(nelements(domain)))

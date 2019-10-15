# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractCoverer

A method for covering spatial objects (e.g. convex hull).
"""
abstract type AbstractCoverer end

"""
    cover(object, coverer)

Cover spatial `object` with `coverer` method.
"""
cover(object::AbstractSpatialObject, coverer::AbstractCoverer) =
  cover(domain(object), coverer)

"""
    cover(domain, coverer)

Cover spatial `domain` with `coverer` method.
"""
cover(domain::AbstractDomain, coverer::AbstractCoverer) = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("covering/rectangle.jl")

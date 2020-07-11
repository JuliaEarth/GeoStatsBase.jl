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
cover(object, coverer::AbstractCoverer) = cover(domain(object), coverer)

"""
    cover(domain, coverer)

Cover spatial `domain` with `coverer` method.
"""
function cover end

#------------------
# IMPLEMENTATIONS
#------------------
include("covering/rectangle.jl")

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractFilter

A method to filter spatial objects.
"""
abstract type AbstractFilter end

"""
    filter(object, filt)

Filter spatial `object` with filtering method `filt`.
"""
function filter end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("filtering/unique_coords.jl")
include("filtering/predicate.jl")
include("filtering/geometry.jl")

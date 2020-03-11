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
Base.filter(object::AbstractSpatialObject, filt::AbstractFilter) =
  @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("filtering/unique_coords.jl")

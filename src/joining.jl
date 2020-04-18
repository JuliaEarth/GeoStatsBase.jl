# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractJoiner

A method for joining spatial objects.
"""
abstract type AbstractJoiner end

"""
    join(object₁, object₂, joiner)

Join spatial object `object₁` and `object₂` with `joiner` method.
"""
Base.join(object₁::AbstractSpatialObject,
          object₂::AbstractSpatialObject,
          joiner::AbstractJoiner) =
  @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("joining/variable.jl")

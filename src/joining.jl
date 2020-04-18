# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractJoiner

A method for joining spatial objects.
"""
abstract type AbstractJoiner end

"""
    join(data₁, data₂, joiner)

Join spatial data `data₁` and ` data₂` with `joiner` method.
"""
Base.join(object₁::AbstractSpatialObject,
          object₂::AbstractSpatialObject,
          joiner::AbstractJoiner) =
  @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("joining/variable.jl")

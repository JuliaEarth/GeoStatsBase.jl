# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractJoiner

A method for joining spatial data.
"""
abstract type AbstractJoiner end

"""
    join(data₁, data₂, joiner)

Join spatial data `data₁` and ` data₂` with `joiner` method.
"""
Base.join(sdata₁::AbstractData, sdata₂::AbstractData, joiner::AbstractJoiner) =
  @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("joining/variable.jl")

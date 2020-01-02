# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDiscretizer

A method for discretizing spatial regions.
"""
abstract type AbstractDiscretizer end

"""
    discretize(region, discretizer)

Discretize spatial `region` with `discretizer` method.
"""
discretize(region::AbstractRegion, discretizer::AbstractDiscretizer) =
  @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("discretizing/regular_grid.jl")

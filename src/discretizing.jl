# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
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
function discretize end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("discretizing/regular_grid.jl")

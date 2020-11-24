# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DiscretizationMethod

A method for discretizing spatial regions.
"""
abstract type DiscretizationMethod end

"""
    discretize(region, method)

Discretize spatial `region` with discretization `method`.
"""
function discretize end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("discretizing/block.jl")

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    FoldingMethod

A method for creating folds out of a spatial object for
cross-validatory error estimation methods.
"""
abstract type FoldingMethod end

"""
    folds(object, method)

Return iterator of folds of `object` according to `method`.
"""
folds(object, method::FoldingMethod) = folds(domain(object), method)

# ----------------
# IMPLEMENTATIONS
# ----------------

include("folding/one.jl")
include("folding/uniform.jl")
include("folding/block.jl")
include("folding/ball.jl")

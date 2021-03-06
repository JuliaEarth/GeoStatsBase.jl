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
function folds end

#------------------
# IMPLEMENTATIONS
#------------------
include("folding/random.jl")
include("folding/point.jl")
include("folding/block.jl")
include("folding/ball.jl")

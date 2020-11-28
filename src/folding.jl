# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    FoldingMethod

A method for creating folds out of a spatial object for
cross-validatory error estimation methods.

Folding methods implement the iterator interface for lazy
construction of folds.
"""
abstract type FoldingMethod end

Base.iterate(method::FoldingMethod, state=1) =
  state > length(method) ? nothing : (method[state], state + 1)

Base.length(method::FoldingMethod) = length(method.subsets)

#------------------
# IMPLEMENTATIONS
#------------------
include("folding/random.jl")
include("folding/block.jl")
include("folding/ball.jl")

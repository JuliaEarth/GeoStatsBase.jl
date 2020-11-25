# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SamplingMethod

A method for sampling from spatial objects.
"""
abstract type SamplingMethod end

"""
    sample(object, method)

Sample elements from `object` with `method`.
"""
function sample end

#------------------
# IMPLEMENTATIONS
#------------------
include("sampling/uniform.jl")
include("sampling/ball.jl")
include("sampling/weighted.jl")

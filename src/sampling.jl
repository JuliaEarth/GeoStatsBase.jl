# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSampler

A method for sampling from spatial objects.
"""
abstract type AbstractSampler end

"""
    sample(object, sampler)

Sample elements from `object` with `sampler`.
"""
function sample end

#------------------
# IMPLEMENTATIONS
#------------------
include("sampling/uniform_sampler.jl")
include("sampling/ball_sampler.jl")
include("sampling/weighted_sampler.jl")

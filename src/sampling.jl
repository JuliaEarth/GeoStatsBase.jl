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
sample(object::AbstractSpatialObject, sampler::AbstractSampler) = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("sampling/uniform_sampler.jl")
include("sampling/ball_sampler.jl")

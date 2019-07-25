# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
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

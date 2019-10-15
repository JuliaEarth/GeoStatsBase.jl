# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractLearningExample

A learning example (e.g. points, tiles with labels).
"""
abstract type AbstractLearningExample end

"""
    Base.iterate(learnexample, state)

Generate a learning example `learnexample` from a given `state`.
"""
Base.iterate(::AbstractLearningExample, state=1) = @error "not implemented"

"""
    AbstractLabeledExample

A learning example for supervised learning tasks.
"""
abstract type AbstractLabeledExample <: AbstractLearningExample end

"""
    AbstractUnlabeledExample

A learning example for unsupervised learning tasks.
"""
abstract type AbstractUnlabeledExample <: AbstractLearningExample end

#------------------
# IMPLEMENTATIONS
#------------------
include("examples/point_example.jl")

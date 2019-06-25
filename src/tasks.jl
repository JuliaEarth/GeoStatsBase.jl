# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractLearningTask

A statistical learning task (e.g. regression, clustering)
"""
abstract type AbstractLearningTask end

"""
    features(task)

Return features of learning `task`.
"""
features(task::AbstractLearningTask) = task.features

"""
    SupervisedLearningTask

A supervised learning task, i.e. training examples are pairs `(x,y)`
with `x ∈ Rⁿ` the features, and `y ∈ R` the labels.
"""
abstract type SupervisedLearningTask <: AbstractLearningTask end

"""
    label(task)

Return label of supervised learning `task`.
"""
label(task::SupervisedLearningTask) = task.label

"""
    UnsupervisedLearningTask

An unsupervised learning task, i.e. training examples are features `x ∈ Rⁿ`.
"""
abstract type UnsupervisedLearningTask <: AbstractLearningTask end

#------------------
# IMPLEMENTATIONS
#------------------
include("tasks/regression.jl")
include("tasks/classification.jl")
include("tasks/clustering.jl")

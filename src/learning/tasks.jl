# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractLearningTask

A statistical learning task (e.g. regression, clustering)
"""
abstract type AbstractLearningTask end

"""
    inputvars(task)

Return the input variables of learning `task`.
"""
inputvars(task::AbstractLearningTask) = features(task)

"""
    outputvars(task)

Return the output variables of learning `task`.
"""
outputvars(task::AbstractLearningTask) = (label(task),)

"""
    issupervised(task)

Check whether or not `task` is supervised.
"""
issupervised(task::AbstractLearningTask) = false

"""
    iscomposite(task)

Check whether or not `task` is composite.
"""
iscomposite(task::AbstractLearningTask) = false

#------------------
# IMPLEMENTATIONS
#------------------
include("tasks/regression.jl")
include("tasks/classification.jl")
include("tasks/clustering.jl")
include("tasks/composite.jl")

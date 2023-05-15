# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearningTask

A statistical learning task (e.g. regression, clustering)
"""
abstract type LearningTask end

"""
    inputvars(task)

Return the input variables of learning `task`.
"""
inputvars(task::LearningTask) = features(task)

"""
    outputvars(task)

Return the output variables of learning `task`.
"""
outputvars(task::LearningTask) = (label(task),)

"""
    issupervised(task)

Check whether or not `task` is supervised.
"""
issupervised(task::LearningTask) = false

# ----------------
# IMPLEMENTATIONS
# ----------------

include("tasks/regression.jl")
include("tasks/classification.jl")

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    issupervised(task)

Check whether or not `task` is supervised.
"""
issupervised(task::AbstractLearningTask) = false
issupervised(task::SupervisedLearningTask) = true
issupervised(task::UnsupervisedLearningTask) = false

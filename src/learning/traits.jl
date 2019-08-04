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

"""
    iscompatible(model, task)

Check whether or not `model` can be used for
learning `task`.
"""
iscompatible(model::MLJBase.Model, task::AbstractLearningTask) = false
iscompatible(model::MLJBase.Model, task::RegressionTask) =
  MLJBase.target_scitype_union(model) == MLJBase.Continuous
iscompatible(model::MLJBase.Model, task::ClassificationTask) =
  MLJBase.target_scitype_union(model) == MLJBase.Count

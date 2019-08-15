# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    iscompatible(model, task)

Check whether or not `model` can be used for
learning `task`.
"""
iscompatible(model::MLJBase.Model, task::AbstractLearningTask) = false
iscompatible(model::MLJBase.Model, task::RegressionTask) =
  MLJBase.target_scitype_union(model) == MLJBase.Continuous
iscompatible(model::MLJBase.Model, task::ClassificationTask) =
  MLJBase.target_scitype_union(model) == MLJBase.Finite

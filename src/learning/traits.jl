# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    iscompatible(model, task)

Check whether or not `model` can be used for
learning `task`.
"""
iscompatible(model::MLJBase.Model, task::AbstractLearningTask) = false
iscompatible(model::MLJBase.Model, task::RegressionTask) = issupervised(model) &&
  (MLJBase.target_scitype(model) == AbstractVector{<:MLJBase.Continuous})
iscompatible(model::MLJBase.Model, task::ClassificationTask) = issupervised(model) &&
  (MLJBase.target_scitype(model) == AbstractVector{<:MLJBase.Finite})
iscompatible(model::MLJBase.Model, task::ClusteringTask) = !issupervised(model)

"""
    isprobabilistic(model)

Check whether or not `model` is probabilistic.
"""
isprobabilistic(model::MLJBase.Model) = false
isprobabilistic(model::MLJBase.Probabilistic) = true

"""
    issupervised(model)

Check whether or not `model` is supervised.
"""
issupervised(model::MLJBase.Model) = false
issupervised(model::MLJBase.Supervised) = true

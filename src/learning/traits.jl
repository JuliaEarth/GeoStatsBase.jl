# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    iscompatible(model, task)

Check whether or not `model` can be used for
learning `task`.
"""
iscompatible(model::MLJBase.Model, task::AbstractLearningTask) = false
iscompatible(model::MLJBase.Model, task::RegressionTask) =
  issupervised(model) && (MLJBase.target_scitype(model) == AbstractVector{Continuous})
iscompatible(model::MLJBase.Model, task::ClassificationTask) =
  issupervised(model) && (MLJBase.target_scitype(model) == AbstractVector{<:Finite})
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

"""
    defaultloss(val)
    defaultloss(scitype)

Default loss for value `val` or its scientific type `scitype`.
"""
defaultloss(val) = defaultloss(scitype(val))
defaultloss(::Type{<:Infinite}) = L2DistLoss()
defaultloss(::Type{<:Finite{2}}) = ZeroOneLoss()

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    iscompatible(model, task)

Check whether or not `model` can be used for
learning `task`.
"""
iscompatible(model::MI.Model, task::AbstractLearningTask) = false
iscompatible(model::MI.Model, task::RegressionTask) =
  issupervised(model) && (MI.target_scitype(model) == AbstractVector{Continuous})
iscompatible(model::MI.Model, task::ClassificationTask) =
  issupervised(model) && (MI.target_scitype(model) == AbstractVector{<:Finite})
iscompatible(model::MI.Model, task::ClusteringTask) = !issupervised(model)

"""
    isprobabilistic(model)

Check whether or not `model` is probabilistic.
"""
isprobabilistic(model::MI.Model) = false
isprobabilistic(model::MI.Probabilistic) = true

"""
    issupervised(model)

Check whether or not `model` is supervised.
"""
issupervised(model::MI.Model) = false
issupervised(model::MI.Supervised) = true

"""
    defaultloss(val)
    defaultloss(scitype)

Default loss for value `val` or its scientific type `scitype`.
"""
defaultloss(val) = defaultloss(scitype(val))
defaultloss(::Type{<:Infinite}) = L2DistLoss()
defaultloss(::Type{<:Finite}) = MisclassLoss()

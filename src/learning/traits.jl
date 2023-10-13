# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    isprobabilistic(model)

Check whether or not `model` is probabilistic.
"""
isprobabilistic(model::MI.Model) = MI.prediction_type(model) == :probabilistic
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
defaultloss(::Type{SciTypes.Continuous}) = L2DistLoss()
defaultloss(::Type{SciTypes.Categorical}) = MisclassLoss()

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractLearningTask

A statistical learning task (e.g. regression, clustering)
"""
abstract type AbstractLearningTask end

"""
    SupervisedLearningTask

A supervised learning task, i.e. training examples are pairs `(x,y)`
with `x` the features, and `y` the labels.
"""
abstract type SupervisedLearningTask <: AbstractLearningTask end

"""
    UnsupervisedLearningTask

An unsupervised learning task, i.e. training examples are features `x`.
"""
abstract type UnsupervisedLearningTask <: AbstractLearningTask end

"""
    RegressionTask

A regression task consists of finding a function `f` such that `y ~ f(x)`
for all training examples `(x,y)` with `y` a continuous variable.
"""
struct RegressionTask{N} <: SupervisedLearningTask
  features::NTuple{N,Symbol}
  label::Symbol
end

"""
    ClassificationTask

A classification task consists of finding a function `f` such that `y ~ f(x)`
for all training examples `(x,y)` with `y` a categorical variable.
"""
struct ClassificationTask{N} <: SupervisedLearningTask
  features::NTuple{N,Symbol}
  label::Symbol
end

"""
    ClusteringTask

A clustering task consists of grouping training examples with features `x`.
"""
struct ClusteringTask{N} <: UnsupervisedLearningTask
  features::NTuple{N,Symbol}
end

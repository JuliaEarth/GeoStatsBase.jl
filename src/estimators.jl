# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Estimator

A geospatial estimator, i.e. an estimator that predicts
variables at given locations based on geospatial data.

An `Estimator` must implement the functions [`fit`](@ref),
[`predict`](@ref) and [`status`](@ref).
"""
abstract type Estimator end

"""
    fit(estimator, data)

Fit estimator to geospatial `data` and return a fitted estimator.
"""
function fit end

"""
    predict(estimator, var, uₒ)

Predict variable `var` with the `estimator` at point or geometry `uₒ`.
"""
function predict end

"""
    status(fitted)

Return the status of the `fitted` estimator. (e.g. the
factorization of the linear system was successful)
"""
function status end

"""
    ProbabilisticEstimator

A geospatial estimator that also support probabilistic predictions
with [`predictprob`](@ref).
"""
abstract type ProbabilisticEstimator end

"""
    predictprob(estimator, var, uₒ)

Predict probability distribution of variable `var` with the
probabilistic `estimator` at point or geometry `uₒ`.
"""
function predictprob end
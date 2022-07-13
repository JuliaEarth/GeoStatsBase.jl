# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Estimator

A geospatial estimator (e.g. Kriging).
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

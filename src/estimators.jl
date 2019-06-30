# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    fit(estimator, X, z)

Fit estimator to coordinates `X` and values `z`,
and return a fitted estimator.
"""
function fit end

"""
    predict(estimator, xₒ)

Predict with the `estimator` at coordinates `xₒ`.
"""
function predict end

"""
    status(fitted)

Return the status of the `fitted` estimator. (e.g. the
factorization of the linear system was successful)
"""
function status end

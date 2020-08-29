# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractErrorEstimator

A method for estimating error of geostatistical solvers.
"""
abstract type AbstractErrorEstimator end

"""
    error(solver, problem, eestimator)

Estimate error of `solver` in a given `problem` with
`eestimator` error estimation method.
"""
function error end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("errors/leave_ball_out.jl")
include("errors/cross_validation.jl")
include("errors/block_cross_validation.jl")
include("errors/weighted_cross_validation.jl")
include("errors/weighted_bootstrap.jl")
include("errors/density_ratio_validation.jl")

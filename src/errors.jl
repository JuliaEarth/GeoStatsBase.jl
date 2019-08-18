# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractErrorEstimator

A method for estimating error of geostatistical solvers.
"""
abstract type AbstractErrorEstimator end

"""
    estimate_error(solver, problem, eestimator)

Estimate error of `solver` in a given `problem` with
`eestimator` error estimation method.
"""
estimate_error(::AbstractSolver, ::AbstractProblem,
               ::AbstractErrorEstimator) = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("errors/leave_ball_out.jl")

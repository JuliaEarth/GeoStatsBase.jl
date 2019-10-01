# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
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
Base.error(::AbstractSolver, ::AbstractProblem,
           ::AbstractErrorEstimator) = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("errors/leave_ball_out.jl")
include("errors/cross_validation.jl")
include("errors/block_cross_validation.jl")

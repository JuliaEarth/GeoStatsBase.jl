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

compare(solvers::AbstractVector{S}, problem::P,
        eestimator::AbstractErrorEstimator) where {S<:AbstractSolver,
                                                   P<:AbstractProblem} =
  [estimate_error(solver, problem, eestimator) for solver in solvers]

#------------------
# IMPLEMENTATIONS
#------------------
include("errors/leave_ball_out.jl")
include("errors/cross_validation.jl")
include("errors/block_cross_validation.jl")

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ErrorEstimationMethod

A method for estimating error of geostatistical solvers.
"""
abstract type ErrorEstimationMethod end

"""
    error(solver, problem, method)

Estimate error of `solver` in a given `problem` with
error estimation `method`.
"""
function error end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("errors/leave_ball_out.jl")
include("errors/cross_validation.jl")
include("errors/block_cross_validation.jl")
include("errors/weighted_cross_validation.jl")
include("errors/density_ratio_validation.jl")

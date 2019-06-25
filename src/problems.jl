# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractProblem

A generic problem in geostatistics.
"""
abstract type AbstractProblem end

#------------------
# IMPLEMENTATIONS
#------------------
include("problems/estimation_problem.jl")
include("problems/simulation_problem.jl")
include("problems/learning_problem.jl")

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractProblem

A generic problem in geostatistics.
"""
abstract type AbstractProblem end

#------------------
# IMPLEMENTATIONS
#------------------
include("problems/estimation.jl")
include("problems/simulation.jl")
include("problems/learning.jl")

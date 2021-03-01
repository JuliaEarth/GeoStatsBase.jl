# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Problem

A generic problem in geostatistics.
"""
abstract type Problem end

#------------------
# IMPLEMENTATIONS
#------------------
include("problems/estimation.jl")
include("problems/simulation.jl")
include("problems/learning.jl")

# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSolution

A generic solution to a problem in geostatistics.
"""
abstract type AbstractSolution end

#------------------
# IMPLEMENTATIONS
#------------------
include("solutions/estimation_solution.jl")
include("solutions/simulation_solution.jl")

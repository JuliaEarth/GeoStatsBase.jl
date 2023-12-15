# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Problem

A generic problem in geostatistics.
"""
abstract type Problem end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("problems/interpolation.jl")
include("problems/learning.jl")

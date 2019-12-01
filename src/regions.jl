# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractRegion

A region in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractRegion{T,N} end

#------------------
# IMPLEMENTATIONS
#------------------
include("regions/rectangle.jl")

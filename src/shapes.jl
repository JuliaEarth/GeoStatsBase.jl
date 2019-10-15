# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractShape

A geometrical shape in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractShape{T,N} end

#------------------
# IMPLEMENTATIONS
#------------------
include("shapes/rectangle.jl")

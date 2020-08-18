# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractGeometry{T,N}

A geometry in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractGeometry{T,N} end

"""
    x ∈ geometry

Check if coordinates `x` are in the `geometry`.
"""
in

#------------------
# IMPLEMENTATIONS
#------------------
include("geometries/rectangle.jl")

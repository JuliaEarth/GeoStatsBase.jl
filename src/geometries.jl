# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractGeometry{T,N}

A geometry in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractGeometry{T,N} end

#------------------
# IMPLEMENTATIONS
#------------------
include("geometries/rectangle.jl")

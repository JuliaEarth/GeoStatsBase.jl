# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractPath

A path on a spatial object.
"""
abstract type AbstractPath end

"""
    traverse(object, path)

Traverse spatial `object` with `path`.
"""
function traverse end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("paths/linear.jl")
include("paths/random.jl")
include("paths/source.jl")
include("paths/shifted.jl")

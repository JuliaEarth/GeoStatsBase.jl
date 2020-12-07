# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    MappingMethod

A method for mapping spatial data onto a domain.
"""
abstract type MappingMethod end

"""
    map(sdata, sdomain, targetvars, method)

Map the `targetvars` in `sdata` to `sdomain` with mapping `method`.
"""
function map end

# ----------------
# IMPLEMENTATIONS
# ----------------
include("mappings/nearest.jl")
include("mappings/copy.jl")

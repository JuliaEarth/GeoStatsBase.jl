# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ErrorMethod

A method for estimating cross-validatory error.
"""
abstract type ErrorMethod end

struct LearnSetup{L,M}
  model::M
  LearnSetup(::Type{L}, model::M) where {L,M} = new{L,M}(model)
end

struct InterpSetup{I,M}
  model::M
  InterpSetup(::Type{I}, model::M) where {I,M} = new{I,M}(model)
end

"""
    error(setup, problem, method)

Estimate error of `setup` in a given `problem` with
error estimation `method`.
"""
Base.error(setup, problem, ::ErrorMethod)

# ----------------
# IMPLEMENTATIONS
# ----------------

include("errors/loo.jl")
include("errors/lbo.jl")
include("errors/kfv.jl")
include("errors/bcv.jl")
include("errors/wcv.jl")
include("errors/drv.jl")

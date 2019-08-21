# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSolverComparison

A method for comparing geostatistical solvers.
"""
abstract type AbstractSolverComparison end

"""
    AbstractEstimSolverComparison

A method for comparing estimation solvers.
"""
abstract type AbstractEstimSolverComparison <: AbstractSolverComparison end

"""
    AbstractSimSolverComparison

A method for comparing simulation solvers.
"""
abstract type AbstractSimSolverComparison <: AbstractSolverComparison end

"""
    AbstractLearnSolverComparison

A method for comparing learning solvers.
"""
abstract type AbstractLearnSolverComparison <: AbstractSolverComparison end

"""
    compare(solvers, problem, method)

Compare `solvers` on a given `problem` using a comparison `method`.
"""
compare(::AbstractVector{S}, ::AbstractProblem,
        ::AbstractSolverComparison) where {S<:AbstractSolver} = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("comparisons/visual.jl")
include("comparisons/cross_validation.jl")

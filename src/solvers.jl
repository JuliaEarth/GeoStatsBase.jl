# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSolver

A solver for geostatistical problems.
"""
abstract type AbstractSolver end

"""
    AbstractEstimationSolver

A solver for a geostatistical estimation problem.
"""
abstract type AbstractEstimationSolver <: AbstractSolver end

"""
    AbstractSimulationSolver

A solver for a geostatistical simulation problem.
"""
abstract type AbstractSimulationSolver <: AbstractSolver end

"""
    AbstractLearningSolver

A solver for a geostatistical learning problem.
"""
abstract type AbstractLearningSolver <: AbstractSolver end

"""
    solve(problem, solver)

Solve the `problem` with the `solver`.
"""
solve(::AbstractProblem, ::AbstractSolver) = @error "not implemented"

"""
    solve(problem, solver)

Solve the simulation `problem` with the simulation `solver`.

### Notes

Default implementation calls `singlesolve` in parallel.
"""
function solve(problem::SimulationProblem, solver::AbstractSimulationSolver)
  # sanity checks
  @assert keys(parameters(solver)) ⊆ keys(variables(problem)) "invalid variable names in solver parameters"

  # optional preprocessing step
  preproc = preprocess(problem, solver)

  realizations = []
  for (var,V) in variables(problem)
    varreals = pmap(1:nreals(problem)) do _
      singlesolve(problem, var, solver, preproc)
    end
    push!(realizations, var => varreals)
  end

  SimulationSolution(domain(problem), Dict(realizations))
end

"""
    preprocess(problem, solver)

Preprocess the simulation `problem` once before generating each realization
with simulation `solver`.

### Notes

The output of the function is defined by the solver developer.
Default implementation returns nothing.
"""
preprocess(::SimulationProblem, ::AbstractSimulationSolver) = nothing

"""
    singlesolve(problem, var, solver, preproc)

Solve a single realization of `var` in the simulation `problem`
with the simulation `solver`, optionally using preprocessed
data in `preproc`.

### Notes

By implementing this function instead of `solve`, the developer is
informing the framework that realizations generated with his/her
solver are indenpendent one from another. GeoStats.jl will trigger
the algorithm in parallel (if enough processes are available).
"""
singlesolve(::SimulationProblem, ::Symbol, ::AbstractSimulationSolver,
            ::Any) = @error "not implemented"

"""
    separablevars(solver)

Return the list of variables that were specified in the `solver` separately.
"""
separablevars(::AbstractSolver) = @error "not implemented"

"""
    nonseparablevars(solver)

Return the list of variables that were specified in the `solver` along
with other variables. For example `(:var₁, :var₂)` specifies that the
two variables `var₁` and `var₂` have shared parameters, hence results.
"""
nonseparablevars(::AbstractSolver) = @error "not implemented"

"""
    parameters(solver, var)

Return the parameters of the separable variable `var` in the `solver`.
"""
parameters(::AbstractSolver, ::Symbol) = @error "not implemented"

"""
    parameters(solver, vars)

Return the parameters of the nonseparable variables `vars` in the `solver`.
"""
parameters(::AbstractSolver, ::NTuple) = @error "not implemented"

"""
    parameters(solver)

Return the parameters of the `solver` for all specified variables.
"""
function parameters(solver::AbstractSolver)
  sdict = Dict(var => parameters(solver, var) for var in separablevars(solver))
  jdict = Dict(var => parameters(solver, var) for var in nonseparablevars(solver))
  merge(sdict, jdict)
end

#------------------
# IMPLEMENTATIONS
#------------------
include("solvers/sequential_simulation.jl")
include("solvers/cookie_cutter_simulation.jl")
include("solvers/pointwise_learning.jl")

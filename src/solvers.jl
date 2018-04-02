# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
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
    solve(problem, solver)

Solve the `problem` with the `solver`.
"""
solve(::AbstractProblem, ::AbstractSolver) = error("not implemented")

"""
    solve(problem, solver)

Solve the simulation `problem` with the simulation `solver`.

### Notes

Default implementation calls `solve_single` in parallel.
"""
function solve(problem::SimulationProblem, solver::AbstractSimulationSolver)
  # sanity checks
  @assert keys(solver.params) ⊆ keys(variables(problem)) "invalid variable names in solver parameters"

  realizations = []
  for (var,V) in variables(problem)
    if nworkers() > 1
      # generate realizations in parallel
      λ = _ -> solve_single(problem, var, solver)
      varreals = pmap(λ, 1:nreals(problem))
    else
      # fallback to serial execution
      varreals = [solve_single(problem, var, solver) for i=1:nreals(problem)]
    end

    push!(realizations, var => varreals)
  end

  SimulationSolution(domain(problem), Dict(realizations))
end

"""
    solve_single(problem, var, solver)

Solve a single realization of `var` in the simulation `problem`
with the simulation `solver`.

### Notes

By implementing this function instead of `solve`, the developer is
informing the framework that realizations generated with his/her
solver are indenpendent one from another. GeoStats.jl will trigger
the algorithm in parallel (if enough processes are available).
"""
solve_single(::SimulationProblem, ::Symbol, ::AbstractSimulationSolver) = error("not implemented")

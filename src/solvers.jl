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

Default implementation calls `solvesingle` in parallel.
"""
function solve(problem::SimulationProblem, solver::AbstractSimulationSolver)
  # sanity checks
  @assert variables(solver) ⊆ keys(variables(problem)) "invalid variables in solver"

  # optional preprocessing
  preproc = preprocess(problem, solver)

  # simulation loop
  results = []
  for covars in covariables(problem, solver)
    # simulate covariables
    reals = pmap(1:nreals(problem)) do _
      solvesingle(problem, covars, solver, preproc)
    end

    # rearrange realizations
    vnames = covars.names
    vtypes = [variables(problem)[var] for var in vnames]
    rdict  = Dict(vnames .=> [Vector{V}[] for V in vtypes])
    for real in reals
      for var in vnames
        push!(rdict[var], real[var])
      end
    end

    push!(results, rdict)
  end

  # merge results into a single dictionary
  pdomain = domain(problem)
  preals  = reduce(merge, results)

  SimulationSolution(pdomain, preals)
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
    solvesingle(problem, covariables, solver, preproc)

Solve a single realization of `covariables` in the simulation `problem`
with the simulation `solver`, optionally using preprocessed data in `preproc`.

### Notes

By implementing this function instead of `solve`, the developer is
informing the framework that realizations generated with his/her
solver are indenpendent one from another. GeoStats.jl will trigger
the algorithm in parallel (if enough processes are available).
"""
solvesingle(::SimulationProblem, ::NamedTuple, ::AbstractSimulationSolver,
            ::Any) = @error "not implemented"

"""
    covariables(var, solver)

Return covariables associated with the variable `var`
in the `solver` and their respective parameters.
"""
covariables(::Symbol, ::AbstractSolver) = @error "not implemented"

"""
    covariables(problem, solver)

Return all covariables in the `solver` based on list of
variables in the `problem`.
"""
function covariables(problem::AbstractProblem, solver::AbstractSolver)
  vars = Set(keys(variables(problem)))

  result = []
  while !isempty(vars)
    # choose a variable from the problem
    var = pop!(vars)

    # find covariables of the variable
    covars = covariables(var, solver)

    # save covariables to result
    push!(result, covars)

    # update remaining variables
    for v in setdiff(covars.names, [var])
      pop!(vars, v)
    end
  end

  result
end

"""
    variables(solver)

Return flattened list of variable names in the `solver`.
"""
variables(::AbstractSolver) = @error "not implemented"

#------------------
# IMPLEMENTATIONS
#------------------
include("solvers/sequential_simulation.jl")
include("solvers/cookie_cutter_simulation.jl")
include("solvers/pointwise_learning.jl")

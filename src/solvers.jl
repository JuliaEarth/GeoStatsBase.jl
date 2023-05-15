# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Solver

A solver for geostatistical problems.
"""
abstract type Solver end

"""
    EstimationSolver

A solver for a geostatistical estimation problem.
"""
abstract type EstimationSolver <: Solver end

"""
    SimulationSolver

A solver for a geostatistical simulation problem.
"""
abstract type SimulationSolver <: Solver end

"""
    LearningSolver

A solver for a geostatistical learning problem.
"""
abstract type LearningSolver <: Solver end

"""
    solve(problem, solver; [options])

Solve the `problem` with the `solver`, optionally
passing `options`.
"""
function solve end

"""
    solve(problem, solver; procs=[myid()])

Solve the simulation `problem` with the simulation `solver`,
optionally using multiple processes `procs`.

### Notes

Default implementation calls `solvesingle` in parallel.
"""
function solve(problem::SimulationProblem, solver::SimulationSolver; procs=[myid()])
  # sanity checks
  @assert targets(solver) ⊆ name.(variables(problem)) "invalid variables in solver"

  # dictionary with variable types
  mactypeof = Dict(name(v) => mactype(v) for v in variables(problem))

  # optional preprocessing
  preproc = preprocess(problem, solver)

  # pool of worker processes
  pool = CachingPool(procs)

  # list of covariables
  allcovars = covariables(problem, solver)

  # simulation loop
  results = []
  for covars in allcovars
    # simulate covariables
    reals = pmap(pool, 1:nreals(problem)) do _
      solvesingle(problem, covars, solver, preproc)
    end

    # rearrange realizations
    vnames = covars.names
    vtypes = [mactypeof[var] for var in vnames]
    vvects = [Vector{V}[] for V in vtypes]
    rtuple = (; zip(vnames, vvects)...)
    for real in reals
      for var in vnames
        push!(rtuple[var], real[var])
      end
    end

    push!(results, rtuple)
  end

  # merge results into a single dictionary
  pdomain = domain(problem)
  preals = reduce(merge, results)

  Ensemble(pdomain, preals)
end

"""
    preprocess(problem, solver)

Preprocess the simulation `problem` once before generating each realization
with simulation `solver`.

### Notes

The output of the function is defined by the solver developer.
Default implementation returns nothing.
"""
preprocess(::SimulationProblem, ::SimulationSolver) = nothing

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
function solvesingle end

"""
    covariables(var, solver)

Return covariables associated with the variable `var`
in the `solver` and their respective parameters.
"""
function covariables end

"""
    covariables(problem, solver)

Return all covariables in the `solver` based on list of
variables in the `problem`.
"""
function covariables(problem::Problem, solver::Solver)
  pvars = collect(name.(variables(problem)))

  result = []
  while !isempty(pvars)
    # choose a variable from the problem
    var = first(pvars)

    # find covariables of the variable
    covars = covariables(var, solver)

    # save covariables to result
    push!(result, covars)

    # update remaining variables
    pvars = setdiff(pvars, covars.names)
  end

  result
end

"""
    targets(solver)

Return target variables in the `solver`.
"""
function targets end

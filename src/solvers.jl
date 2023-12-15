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
  pvars = keys(variables(problem))

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

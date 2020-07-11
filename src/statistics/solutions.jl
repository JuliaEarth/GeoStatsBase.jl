# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    mean(solution)

Mean of simulation `solution`.
"""
function mean(solution::SimulationSolution)
  data = DataFrame([variable => mean(reals) for (variable, reals) in solution.realizations])
  georef(data, solution.domain)
end

"""
    var(solution)

Variance of simulation `solution`.
"""
function var(solution::SimulationSolution)
  data = DataFrame([variable => var(reals) for (variable, reals) in solution.realizations])
  georef(data, solution.domain)
end

"""
    quantile(solution, p)

p-quantile of simulation `solution`.
"""
function quantile(solution::SimulationSolution, p::Number)
  cols = []
  for (variable, reals) in solution.realizations
    quantiles = map(1:npoints(solution.domain)) do location
      slice = getindex.(reals, location)
      quantile(slice, p)
    end
    push!(cols, variable => quantiles)
  end
  georef(DataFrame(cols), solution.domain)
end

quantile(solution::SimulationSolution, ps::AbstractVector) = [quantile(solution, p) for p in ps]

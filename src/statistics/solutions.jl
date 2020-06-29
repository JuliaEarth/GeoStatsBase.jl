# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    mean(solution)

Mean of simulation `solution`.
"""
function mean(solution::SimulationSolution)
  data = DataFrame(variable => mean(reals) for (variable, reals) in solution.realizations)
  SpatialStatistic(solution.domain, data)
end

"""
    var(solution)

Variance of simulation `solution`.
"""
function var(solution::SimulationSolution)
  data = DataFrame(variable => var(reals) for (variable, reals) in solution.realizations)
  SpatialStatistic(solution.domain, data)
end

"""
    quantile(solution, p)

p-quantile of simulation `solution`.
"""
function quantile(solution::SimulationSolution, p::Number)
  data = []
  for (variable, reals) in solution.realizations
    quantiles = map(1:npoints(solution.domain)) do location
      slice = getindex.(reals, location)
      quantile(slice, p)
    end
    push!(data, variable => quantiles)
  end
  SpatialStatistic(solution.domain, DataFrame(data))
end

quantile(solution::SimulationSolution, ps::AbstractVector) = [quantile(solution, p) for p in ps]

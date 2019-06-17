# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    mean(solution)

Mean of simulation `solution`.
"""
function mean(solution::SimulationSolution)
  data = Dict(variable => mean(reals) for (variable, reals) in solution.realizations)
  SpatialStatistic(data, solution.domain)
end

"""
    var(solution)

Variance of simulation `solution`.
"""
function var(solution::SimulationSolution)
  data = Dict(variable => var(reals) for (variable, reals) in solution.realizations)
  SpatialStatistic(data, solution.domain)
end

"""
    quantile(solution, p)

p-quantile of simulation `solution`.
"""
function quantile(solution::SimulationSolution, p::Real)
  data = []
  for (variable, reals) in solution.realizations
    quantiles = map(1:npoints(solution.domain)) do location
      slice = getindex.(reals, location)
      quantile(slice, p)
    end
    push!(data, variable => quantiles)
  end

  SpatialStatistic(Dict(data), solution.domain)
end

quantile(solution::SimulationSolution, ps::AbstractVector) = [quantile(solution, p) for p in ps]

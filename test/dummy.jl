import GeoStatsBase: solve_single

# dummy simulation solver
@simsolver Dummy begin end
function solve_single(problem::SimulationProblem,
                      var::Symbol, solver::Dummy, preproc)
  npts = npoints(domain(problem))
  V = variables(problem)[var]
  vcat(fill(zero(V), npts÷2), fill(one(V), npts÷2))
end

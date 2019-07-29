################
# DUMMY SOLVER
################
import GeoStatsBase: solve_single

@simsolver DummySimSolver begin end
function solve_single(problem::SimulationProblem,
                      var::Symbol, solver::DummySimSolver, preproc)
  npts = npoints(domain(problem))
  V = variables(problem)[var]
  vcat(fill(zero(V), npts÷2), fill(one(V), npts÷2))
end

###################
# DUMMY ESTIMATOR
###################
import GeoStatsBase: fit, predict, status

struct DummyEstimator end
struct FittedDummyEstimator
  z
end

fit(estimator::DummyEstimator, X, z) = FittedDummyEstimator(z)
function predict(fitted::FittedDummyEstimator, xₒ)
  z  = fitted.z
  μ  = sum(z) / length(z)
  σ² = sum((v - μ)^2 for v in z) / length(z)
  μ, σ²
end
status(fitted::FittedDummyEstimator) = true

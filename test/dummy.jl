#################
# DUMMY SOLVERS
#################
import GeoStatsBase: solve, solvesingle

@estimsolver DummyEstimSolver begin end
function solve(problem::EstimationProblem, solver::DummyEstimSolver)
  sdat = data(problem)
  sdom = domain(problem)
  npts = npoints(sdom)
  vars = [v for (v,V) in variables(problem)]
  μvar = Dict(v => fill(mean(sdat[v]),npts) for v in vars)
  σvar = Dict(v => fill(var(sdat[v]),npts) for v in vars)
  EstimationSolution(sdom, μvar, σvar)
end

@simsolver DummySimSolver begin end
function solvesingle(problem::SimulationProblem, covars::NamedTuple,
                     solver::DummySimSolver, preproc)
  reals = map(covars.names) do var
    npts = npoints(domain(problem))
    V    = variables(problem)[var]
    real = vcat(fill(zero(V), npts÷2), fill(one(V), npts÷2))
    var => real
  end
  Dict(reals)
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

#########################
# OTHER EXAMPLE SOLVERS
#########################
@estimsolver ESolver begin
  @param A=1.0
  @param B=2
  @jparam J="foo"
  @global C=true
end

@simsolver SSolver begin
  @param A=1.0
  @param B=2
  @jparam J="foo"
  @global C=true
end

########################
# DUMMY LEARNING MODEL
########################
import GeoStatsBase: issupervised
import MLJModelInterface
const MI = MLJModelInterface

struct DummyModel <: MI.Supervised end
MI.fit(m::DummyModel, v, X, y) = rand(unique(y),length(y)), 0, 0
MI.predict(m::DummyModel, θ, X) = θ
MI.target_scitype(m::DummyModel) = AbstractVector{<:MI.Finite}

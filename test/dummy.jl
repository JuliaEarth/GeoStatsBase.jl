#################
# DUMMY SOLVERS
#################
import GeoStatsBase: solve, solvesingle

@estimsolver DummyEstimSolver begin end
function solve(problem::EstimationProblem, solver::DummyEstimSolver)
  sdat = data(problem)
  sdom = domain(problem)
  npts = nelements(sdom)
  vars = name.(variables(problem))
  μs = [v => fill(mean(sdat[v]), npts) for v in vars]
  σs = [Symbol(v,:Var) => fill(var(sdat[v]), npts) for v in vars]
  georef((; μs..., σs...), sdom)
end

###################
# EXAMPLE SOLVERS
###################
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
import MLJModelInterface
const MI = MLJModelInterface

struct DummyModel <: MI.Supervised end
MI.fit(m::DummyModel, v, X, y) = rand(unique(y),length(y)), 0, 0
MI.predict(m::DummyModel, θ, X) = rand(θ, Tables.rowcount(X))
MI.target_scitype(m::DummyModel) = AbstractVector{<:MI.Finite}

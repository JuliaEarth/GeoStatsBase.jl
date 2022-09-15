import GeoStatsBase: solve, solvesingle
import MLJModelInterface

const MI = MLJModelInterface

########################
# DUMMY LEARNING MODEL
########################

struct DummyModel <: MI.Supervised end
MI.fit(m::DummyModel, v, X, y) = rand(unique(y),length(y)), 0, 0
MI.predict(m::DummyModel, θ, X) = rand(θ, Tables.rowcount(X))
MI.target_scitype(m::DummyModel) = AbstractVector{<:MI.Finite}

#################
# DUMMY SOLVERS
#################

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

function solvesingle(problem::SimulationProblem, covars, ::SSolver, preproc)
  Dict(var => rand(100) for var in covars.names)
end

struct DummyLearnSolver{M} <: LearningSolver
  model::M
end

function solve(problem::LearningProblem, solver::DummyLearnSolver)
  sdata = sourcedata(problem)
  tdata = targetdata(problem)
  ptask = task(problem)
  model = solver.model

  # learn task with source data
  stable = values(sdata)
  if issupervised(ptask)
    X = stable |> Select(features(ptask))
    y = Tables.getcolumn(stable, label(ptask))
    θ, _, __ = MI.fit(model, 0, X, y)
  else
    X = stable |> Select(features(ptask))
    θ, _, __ = MI.fit(model, 0, X)
  end

  # perform task with target data
  ttable = values(tdata)
  X = ttable |> Select(features(ptask))
  ŷ = MI.predict(model, θ, X)

  # post-process result
  var = outputvars(ptask)[1]
  val = if issupervised(ptask)
    isprobabilistic(model) ? mode.(ŷ) : ŷ
  else
    ŷ
  end

  # georeference on target domain
  ctor = constructor(typeof(tdata))
  dom  = domain(tdata)
  dat  = Dict(paramdim(dom) => (; var=>val))

  ctor(dom, dat)
end

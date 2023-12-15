import GeoStatsBase: solve

########################
# DUMMY LEARNING MODEL
########################

struct DummyModel end
fit(::DummyModel, v, X, y) = rand(unique(y), length(y)), 0, 0
predict(::DummyModel, θ, X) = rand(θ, Tables.rowcount(X))

#################
# DUMMY SOLVERS
#################

@estimsolver DummyEstimSolver begin end
function solve(problem::EstimationProblem, solver::DummyEstimSolver)
  sdat = data(problem)
  sdom = domain(problem)
  npts = nelements(sdom)
  vars = keys(variables(problem))
  μs = [v => fill(mean(getproperty(sdat, v)), npts) for v in vars]
  σs = [Symbol(v, :Var) => fill(var(getproperty(sdat, v)), npts) for v in vars]
  georef((; μs..., σs...), sdom)
end

@estimsolver ESolver begin
  @param A = 1.0
  @param B = 2
  @jparam J = "foo"
  @global C = true
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
    θ, _, __ = fit(model, 0, X, y)
  else
    X = stable |> Select(features(ptask))
    θ, _, __ = fit(model, 0, X)
  end

  # perform task with target data
  ttable = values(tdata)
  X = ttable |> Select(features(ptask))
  ŷ = predict(model, θ, X)

  # post-process result
  var = outputvars(ptask)[1]
  val = ŷ

  # georeference on target domain
  ctor = constructor(typeof(tdata))
  dom = domain(tdata)
  dat = Dict(paramdim(dom) => (; var => val))

  ctor(dom, dat)
end

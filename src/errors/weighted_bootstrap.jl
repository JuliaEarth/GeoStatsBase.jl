# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedBootstrap(weighter, nsamples; loss=Dict())

Weighted bootstrap with `nsamples` samples drawn with
replacement using the weights produced by `weighter`.
Optionally, specify `loss` function from `LossFunctions.jl`
for some of the variables.
"""
struct WeightedBootstrap{W<:AbstractWeighter} <: AbstractErrorEstimator
  weighter::W
  nsamples::Int
  loss::Dict{Symbol,SupervisedLoss}
end

WeightedBootstrap(weighter::AbstractWeighter, nsamples::Int; loss=Dict()) =
  WeightedBootstrap{typeof(weighter)}(weighter, nsamples, loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               eestimator::WeightedBootstrap)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  loss  = eestimator.loss
  nboot = eestimator.nsamples
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # weight source data
  weights = weight(sdata, eestimator.weighter)

  # error for bootstrap sample
  function ε()
    # bootstrap sample
    bsize = nelms(sdata)
    sinds = sample(1:bsize, bsize, replace=true)
    binds = sample(1:bsize, weights, bsize, replace=true)
    tinds = setdiff(binds, sinds)

    # source and target data
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = LearningProblem(train, hold, task(problem))
    solution   = solve(subproblem, solver)

    # loss for each variable
    losses = map(ovars) do var
      y = hold[var]
      ŷ = solution[var]
      ℒ = value(loss[var], y, ŷ, AggMode.Mean())
      var => ℒ
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), 1:nfolds)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end
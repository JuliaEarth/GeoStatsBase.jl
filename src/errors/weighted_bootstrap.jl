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
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[1,var])
    end
  end

  # bootstrap parameters
  b = eestimator.nsamples
  n = npoints(sdata)

  # weight source data
  weights = weight(sdata, eestimator.weighter)

  results = pmap(1:b) do _
    # create bootstrap sample
    sinds = sample(1:n, n, replace=true)
    binds = sample(1:n, weights, n, replace=true)
    tinds = setdiff(binds, sinds)

    # training and holdout set
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # solve problem for this sample
    subproblem = LearningProblem(train, hold, task(problem))
    solution   = solve(subproblem, solver)

    result = map(ovars) do var
      y = hold[var]
      ŷ = solution[var]
      var => value(loss[var], y, ŷ, AggMode.Mean())
    end

    # results for bootstrap sample
    Dict(result)
  end

  # average results across samples
  sums = reduce((r₁, r₂) -> merge(+, r₁, r₂), results)
  Dict(var => val / b for (var, val) in sums)
end

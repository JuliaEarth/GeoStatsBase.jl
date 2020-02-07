# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedBootstrap(weighter, b)

Weighted bootstrap with `b` samples drawn with replacement
using the weights produced by `weighter`.
"""
struct WeightedBootstrap{W<:AbstractWeighter} <: AbstractErrorEstimator
  weighter::W
  b::Int
end

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::WeightedBootstrap)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))

  # bootstrap parameters
  b = eestimator.b
  n = npoints(sdata)

  # weights source data
  weights = weight(sdata, eestimator.weighter)

  results = pmap(1:b) do _
    # create bootstrap sample
    sinds = sample(1:n, weights, n, replace=true)
    tinds = setdiff(1:n, sinds)

    # training and holdout set
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # solve problem for this sample
    subproblem = LearningProblem(train, hold, task(problem))
    solution   = solve(subproblem, solver)

    # weights for holdout set
    w = view(weights, tinds)

    result = map(ovars) do var
      𝔏 = defaultloss(sdata[1,var])
      ŷ = solution[var]
      y = hold[var]
      var => 𝔏(ŷ, y, w)
    end

    # results for bootstrap sample
    Dict(result)
  end

  # average results across samples
  sums = reduce((r₁, r₂) -> merge(+, r₁, r₂), results)
  Dict(var => val / b for (var, val) in sums)
end

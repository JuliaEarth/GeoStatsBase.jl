# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedLossValidation(weighter, fraction)

Weighted loss validation with train / hold-out split.
The source data of the problem is split with a `fraction`
into train and hold-out sets, and the samples are weighted
with a `weighter` method.

## References

* Sugiyama et al. 2012. Density ratio estimation in
  machine learning.
"""
struct WeightedLossValidation{W<:AbstractWeighter,T<:Real} <: AbstractErrorEstimator
  weighter::W
  fraction::T
end

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::WeightedLossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))

  # train and hold-out sets
  partitioner = FractionPartitioner(eestimator.fraction)
  train, hold = partition(sdata, partitioner)

  # solve subproblem
  subproblem = LearningProblem(train, hold, task(problem))
  solution   = solve(subproblem, solver)

  # weight hold-out set
  weights = weight(hold, eestimator.weighter)

  # normalize weights
  w = weights ./ sum(weights)

  result = pmap(ovars) do var
    𝔏 = defaultloss(sdata[1,var])
    ŷ, y = solution[var], hold[var]
    var => 𝔏(ŷ, y, w)
  end

  Dict(result)
end

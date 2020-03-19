# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedHoldOut(weighter, fraction)

Weighted loss validation with train / hold-out split.
The source data of the problem is split with a `fraction`
into train and hold-out sets, and the samples are weighted
with a `weighter` method.
"""
struct WeightedHoldOut{W<:AbstractWeighter,T<:Real} <: AbstractErrorEstimator
  weighter::W
  fraction::T
end

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::WeightedHoldOut)
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
  w = weight(hold, eestimator.weighter)

  result = pmap(ovars) do var
    𝔏 = defaultloss(sdata[1,var])
    ŷ, y = solution[var], hold[var]
    var => value(𝔏, ŷ, y, AggMode.WeightedSum(w)) /length(y)
  end

  Dict(result)
end

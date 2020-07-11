# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedHoldOut(weighter, fraction; loss=Dict())

Weighted loss validation with train / hold-out split.
The source data of the problem is split with a `fraction`
into train and hold-out sets, and the samples are weighted
with a `weighter` method. Optionally, specify `loss` function
from `LossFunctions.jl` for some of the variables.
"""
struct WeightedHoldOut{W<:AbstractWeighter,T<:Real} <: AbstractErrorEstimator
  weighter::W
  fraction::T
  loss::Dict{Symbol,SupervisedLoss}
end

WeightedHoldOut(weighter::AbstractWeighter, fraction::Real; loss=Dict()) =
  WeightedHoldOut{typeof(weighter),typeof(fraction)}(weighter, fraction, loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               eestimator::WeightedHoldOut)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  loss  = eestimator.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[1,var])
    end
  end

  # train and hold-out sets
  partitioner = FractionPartitioner(eestimator.fraction)
  train, hold = partition(sdata, partitioner)

  # solve subproblem
  subproblem = LearningProblem(train, hold, task(problem))
  solution   = solve(subproblem, solver)

  # weight hold-out set
  w = weight(hold, eestimator.weighter)

  result = pmap(ovars) do var
    y = hold[var]
    ŷ = solution[var]
    var => value(loss[var], y, ŷ, AggMode.WeightedSum(w)) /length(y)
  end

  Dict(result)
end

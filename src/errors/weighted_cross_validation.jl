# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedCrossValidation(weighter, partitioner)
    WeightedCrossValidation(weighter, k; shuffle=true)

Weighted cross-validation in which samples are split
into folds with `partitioner` method and are weighted
with `weighter` method. Alternatively, specify the
desired number of folds `k` and `shuffle` options for
a `UniformPartitioner`.
"""
struct WeightedCrossValidation{W<:AbstractWeighter,
                               P<:AbstractPartitioner} <: AbstractErrorEstimator
  weighter::W
  partitioner::P
end

WeightedCrossValidation(weighter::W, k::Int;
                        shuffle=true)  where {W<:AbstractWeighter} =
  WeightedCrossValidation(weighter, UniformPartitioner(k, shuffle))

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::WeightedCrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))

  # folds for cross-validation
  folds  = subsets(partition(sdata, eestimator.partitioner))
  nfolds = length(folds)

  solutions = pmap(1:nfolds) do k
    # source and target indices
    sinds = [ind for i in vcat(1:k-1, k+1:nfolds) for ind in folds[i]]
    tinds = folds[k]

    # source and target data
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = LearningProblem(train, hold, task(problem))
    solve(subproblem, solver)
  end

  # weight all samples
  weights = weight(sdata, eestimator.weighter)

  result = pmap(ovars) do var
    𝔏 = defaultloss(sdata[1,var])
    losses = map(1:nfolds) do k
      hold = view(sdata, folds[k])
      w = view(weights, folds[k])
      ŷ = solutions[k][var]
      y = hold[var]
      𝔏(ŷ, y, w)
    end
    var => mean(losses)
  end

  Dict(result)
end

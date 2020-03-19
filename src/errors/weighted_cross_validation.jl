# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedCrossValidation(weighter, partitioner; lambda=1.0)
    WeightedCrossValidation(weighter, k; shuffle=true, lambda=1.0)

Weighted cross-validation in which samples are split
into folds with `partitioner` method and are weighted
with `weighter` method. Alternatively, specify the
desired number of folds `k` and `shuffle` options for
a `UniformPartitioner`. In all cases, weights can be
raised to `lambda` power.
"""
struct WeightedCrossValidation{W<:AbstractWeighter,
                               P<:AbstractPartitioner,
                               T<:Real} <: AbstractErrorEstimator
  weighter::W
  partitioner::P
  lambda::T

  function WeightedCrossValidation{W,P,T}(weighter, partitioner, lambda) where {W,P,T}
    @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1] interval"
    new(weighter, partitioner, lambda)
  end
end

WeightedCrossValidation(weighter::W, partitioner::P;
                        lambda=1.0) where {W<:AbstractWeighter,
                                           P<:AbstractPartitioner} =
  WeightedCrossValidation{W,P,typeof(lambda)}(weighter, partitioner, lambda)

WeightedCrossValidation(weighter::W, k::Int;
                        shuffle=true, lambda=1.0) where {W<:AbstractWeighter} =
  WeightedCrossValidation(weighter, UniformPartitioner(k, shuffle), lambda=lambda)

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
  weights = weight(sdata, eestimator.weighter) .^ eestimator.lambda

  result = pmap(ovars) do var
    𝔏 = defaultloss(sdata[1,var])
    losses = map(1:nfolds) do k
      hold = view(sdata, folds[k])
      w = view(weights, folds[k])
      ŷ = solutions[k][var]
      y = hold[var]
      value(𝔏, ŷ, y, AggMode.WeightedSum(w)) / length(y)
    end
    var => mean(losses)
  end

  Dict(result)
end

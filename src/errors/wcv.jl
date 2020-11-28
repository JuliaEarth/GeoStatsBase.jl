# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedCrossValidation(weighter, k; shuffle=true,
                            lambda=1.0, loss=Dict())

Weighted cross-validation in which samples are split into `k` folds
and are weighted with `weighter` method. Weights are raised to `lambda`
power in `[0,1]`. Optionally, `shuffle` the samples in folds and specify
`loss` function from `LossFunctions.jl` for some of the variables.

## References

* Sugiyama et al. 2006. [Importance-weighted cross-validation for
  covariate shift](https://link.springer.com/chapter/10.1007/11861898_36)
* Sugiyama et al. 2007. [Covariate shift adaptation by importance weighted
  cross validation](http://www.jmlr.org/papers/volume8/sugiyama07a/sugiyama07a.pdf)
"""
struct WeightedCrossValidation{W<:WeightingMethod,T<:Real} <: ErrorEstimationMethod
  weighter::W
  k::Int
  shuffle::Bool
  lambda::T
  loss::Dict{Symbol,SupervisedLoss}

  function WeightedCrossValidation{W,T}(weighter, k, shuffle, lambda, loss) where {W,T}
    @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
    new(weighter, k, shuffle, lambda, loss)
  end
end

WeightedCrossValidation(weighter::W, k::Int; shuffle=true,
                        lambda::T=one(T), loss=Dict()) where {W,T} =
  WeightedCrossValidation{W,T}(weighter, k, shuffle, lambda, loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::WeightedCrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  weighter = method.weighter
  nfolds   = method.k
  shuffle  = method.shuffle
  lambda   = method.lambda
  loss     = method.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # weight all samples
  ws = weight(sdata, weighter) .^ lambda

  # folds for cross-validation
  fs = folds(sdata, RandomFolding(nfolds, shuffle))

  # error for a fold
  function ε(f)
    # source and target data
    sinds, tinds = f
    source = view(sdata, sinds)
    target = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = LearningProblem(source, target, task(problem))
    solution   = solve(subproblem, solver)

    # loss for each variable
    losses = map(ovars) do var
      y = target[var]
      ŷ = solution[var]
      w = view(ws, tinds)
      ℒ = value(loss[var], y, ŷ, AggMode.WeightedSum(w)) / length(y)
      var => ℒ
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), fs)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

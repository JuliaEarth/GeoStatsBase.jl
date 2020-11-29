# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedCrossValidation(weigthing, folding; lambda=1.0, loss=Dict())

An error estimation method which samples are weighted with
`weighting` method and split into folds with `folding` method.
Weights are raised to `lambda` power in `[0,1]`. Optionally,
specify `loss` function from `LossFunctions.jl` for some of
the variables.

## References

* Sugiyama et al. 2006. [Importance-weighted cross-validation for
  covariate shift](https://link.springer.com/chapter/10.1007/11861898_36)
* Sugiyama et al. 2007. [Covariate shift adaptation by importance weighted
  cross validation](http://www.jmlr.org/papers/volume8/sugiyama07a/sugiyama07a.pdf)
"""
struct WeightedCrossValidation{W<:WeightingMethod,
                               F<:FoldingMethod,
                               T<:Real} <: ErrorEstimationMethod
  weighting::W
  folding::F
  lambda::T
  loss::Dict{Symbol,SupervisedLoss}

  function WeightedCrossValidation{W,F,T}(weighting, folding,
                                          lambda, loss) where {W,F,T}
    @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
    new(weighting, folding, lambda, loss)
  end
end

WeightedCrossValidation(weighting::W, folding::F;
                        lambda::T=one(T), loss=Dict()) where {W,F,T} =
  WeightedCrossValidation{W,F,T}(weighting, folding, lambda, loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::WeightedCrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  weighting = method.weighting
  folding   = method.folding
  lambda    = method.lambda
  loss      = method.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # weight all samples
  ws = weight(sdata, weighting) .^ lambda

  # folds for cross-validation
  fs = folds(sdata, folding)

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

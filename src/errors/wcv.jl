# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedValidation(weighting, folding; lambda=1.0, loss=Dict())

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
struct WeightedValidation{W<:WeightingMethod,F<:FoldingMethod,T<:Real} <: ErrorEstimationMethod
  weighting::W
  folding::F
  lambda::T
  loss::Dict{Symbol,SupervisedLoss}

  function WeightedValidation{W,F,T}(weighting, folding, lambda, loss) where {W,F,T}
    @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
    new(weighting, folding, lambda, loss)
  end
end

WeightedValidation(weighting::W, folding::F; lambda::T=one(T), loss=Dict()) where {W,F,T} =
  WeightedValidation{W,F,T}(weighting, folding, lambda, loss)

function Base.error(solver, problem, method::WeightedValidation)
  # retrieve problem info
  sdata = _foldable(problem)
  ovars = _outputvars(problem)
  loss = method.loss
  for var in ovars
    if var ∉ keys(loss)
      v = getproperty(sdata, var)
      loss[var] = defaultloss(v[1])
    end
  end

  # weight all samples
  ws = weight(sdata, method.weighting) .^ method.lambda

  # folds for cross-validation
  fs = folds(sdata, method.folding)

  # error for a fold
  function ε(f)
    # setup and solve sub-problem
    subproblem = _subproblem(problem, f)
    solution = solve(subproblem, solver)

    # holdout set
    holdout = _holdout(problem, f)

    # holdout weights
    𝓌 = view(ws, f[2])

    # loss for each variable
    losses = map(ovars) do var
      ℒ = loss[var]
      ŷ = getproperty(solution, var)
      y = getproperty(holdout, var)
      var => mean(ℒ, ŷ, y, 𝓌, normalize=false)
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), fs)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

# foldable data of the problem
_foldable(p::EstimationProblem) = data(p)
_foldable(p::LearningProblem) = sourcedata(p)

# output variables of the problem
_outputvars(p::EstimationProblem) = keys(variables(p))
_outputvars(p::LearningProblem) = outputvars(task(p))

# subproblem for a given fold
function _subproblem(p::EstimationProblem, f)
  sdat = view(data(p), f[1])
  sdom = view(domain(data(p)), f[2])
  vars = keys(variables(p))
  EstimationProblem(sdat, sdom, vars)
end
function _subproblem(p::LearningProblem, f)
  source = view(sourcedata(p), f[1])
  target = view(sourcedata(p), f[2])
  LearningProblem(source, target, task(p))
end

# holdout set for a given fold
_holdout(p::EstimationProblem, f) = view(data(p), f[2])
_holdout(p::LearningProblem, f) = view(sourcedata(p), f[2])

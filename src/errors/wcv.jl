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
struct WeightedValidation{W<:WeightingMethod,F<:FoldingMethod,T<:Real} <: ErrorMethod
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

function Base.error(setup, problem, method::WeightedValidation)
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
    # solve sub-problem
    solution = _solution(setup, problem, f)

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
_foldable(p::InterpProblem) = data(p)
_foldable(p::LearnProblem) = sourcedata(p)

# output variables of the problem
_outputvars(p::InterpProblem) = keys(variables(p))
_outputvars(p::LearnProblem) = outputvars(task(p))

# solution for a given fold
function _solution(s::InterpSetup{I}, p::InterpProblem, f) where {I}
  sdat = view(data(p), f[1])
  sdom = view(domain(data(p)), f[2])
  sdat |> I(sdom, s.model)
end

function _solution(s::LearnSetup{L}, p::LearnProblem, f) where {L}
  ptask = task(p)
  source = view(sourcedata(p), f[1])
  target = view(sourcedata(p), f[2])
  target |> L(source, s.model, inputvars(ptask) => outputvars(ptask))
end

# holdout set for a given fold
_holdout(p::InterpProblem, f) = view(data(p), f[2])
_holdout(p::LearnProblem, f) = view(sourcedata(p), f[2])

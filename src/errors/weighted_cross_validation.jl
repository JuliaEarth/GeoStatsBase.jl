# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedCrossValidation(weighter, partitioner;
                            lambda=1.0, loss=Dict())

Weighted cross-validation in which samples are split into folds with
`partitioner` method and are weighted with `weighter` method. Weights
are raised to `lambda` power in `[0,1]`. Optionally, specify `loss`
function from `LossFunctions.jl` for some of the variables.

    WeightedCrossValidation(weighter, k; shuffle=true,
                            lambda=1.0, loss=Dict())

Alternatively, specify the desired number of folds `k` and `shuffle`
options for a `UniformPartitioner`.

## References

* Sugiyama et al. 2006. [Importance-weighted cross-validation for
  covariate shift](https://link.springer.com/chapter/10.1007/11861898_36)
* Sugiyama et al. 2007. [Covariate shift adaptation by importance weighted
  cross validation](http://www.jmlr.org/papers/volume8/sugiyama07a/sugiyama07a.pdf)
"""
struct WeightedCrossValidation{W<:AbstractWeighter,
                               P<:AbstractPartitioner,
                               T<:Real} <: AbstractErrorEstimator
  weighter::W
  partitioner::P
  lambda::T
  loss::Dict{Symbol,SupervisedLoss}

  function WeightedCrossValidation{W,P,T}(weighter, partitioner, lambda, loss) where {W,P,T}
    @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
    new(weighter, partitioner, lambda, loss)
  end
end

WeightedCrossValidation(weighter::W, partitioner::P;
                        lambda=1.0, loss=Dict()) where {W<:AbstractWeighter,
                                                        P<:AbstractPartitioner} =
  WeightedCrossValidation{W,P,typeof(lambda)}(weighter, partitioner, lambda, loss)

WeightedCrossValidation(weighter::W, k::Int; shuffle=true,
                        lambda=1.0, loss=Dict()) where {W<:AbstractWeighter} =
  WeightedCrossValidation(weighter, UniformPartitioner(k, shuffle), lambda=lambda, loss=loss)

function error(solver::AbstractSolver,
               problem::AbstractProblem,
               eestimator::WeightedCrossValidation)

  @assert !isa(problem, SimulationProblem) "not available for SimulationProblem"
  # problem info
  probtype = typeof(problem)
  EP = probtype <: EstimationProblem ? true : false
  sdata = EP ? data(problem) : sourcedata(problem)
  ovars = EP ? [v for (v,V) in variables(problem)] : outputvars(task(problem))
  partitioner = eestimator.partitioner
  weighter = eestimator.weighter
  lambda = eestimator.lambda
  loss  = eestimator.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # weight all samples
  weights = weight(sdata, weighter) .^ lambda

  # folds for cross-validation
  folds  = subsets(partition(sdata, partitioner))
  nfolds = length(folds)
  probcall = getfield(Main, nameof(probtype))
  thirdarg = EP ? Tuple(ovars) : task(problem)

  # error for a fold k
  function ε(k)
    # source and target indices
    sinds = [ind for i in [1:k-1; k+1:nfolds] for ind in folds[i]]
    tinds = folds[k]

    # source and target data
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = probcall(train, hold, thirdarg)
    solution   = solve(subproblem, solver)

    # loss for each variable
    losses = map(ovars) do var
      y = hold[var]
      ŷ = solution[var]
      w = view(weights, tinds)
      ℒ = value(loss[var], y, ŷ, AggMode.WeightedSum(w)) / length(y)
      var => ℒ
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), 1:nfolds)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

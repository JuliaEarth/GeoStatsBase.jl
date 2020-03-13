# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioValidation(k; [options])

Desntity ratio validation where weights are first obtained with density
ratio estimation, and then used in `k`-fold weighted cross-validation.

## Options

* `estimator` - Density ratio estimator (default to `LSIF()`)
* `optlib`    - Optimization library (default to `default_optlib(estimator)`)
* `lambda`    - Power of density ratios (default to `1.0`)
"""
struct DensityRatioValidation{T,E,O} <: AbstractErrorEstimator
  k::Int
  lambda::T
  dre::E
  optlib::O
end

function DensityRatioValidation(k::Int; lambda=1.0, estimator=LSIF(),
                                optlib=default_optlib(estimator))
  @assert k > 0 "number of folds must be positive"
  @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
  T = typeof(lambda)
  E = typeof(estimator)
  O = typeof(optlib)
  DensityRatioValidation{T,E,O}(k, lambda, estimator, optlib)
end

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::DensityRatioValidation)
  # weight samples based on the features of target data
  DΩt  = targetdata(problem)
  vars = collect(features(task(problem)))
  weighter = DensityRatioWeighter(DΩt, variables=vars,
                                  estimator=eestimator.dre,
                                  optlib=eestimator.optlib)
  wcv = WeightedCrossValidation(weighter,
                                eestimator.k, shuffle=true,
                                lambda=eestimator.lambda)
  error(solver, problem, wcv)
end

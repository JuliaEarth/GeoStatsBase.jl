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
"""
struct DensityRatioValidation <: AbstractErrorEstimator
  k::Int
  dre
  optlib
end

DensityRatioValidation(k::Int; estimator=LSIF(),
                       optlib=default_optlib(estimator)) =
  DensityRatioValidation(k, estimator, optlib)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::DensityRatioValidation)
  # weight samples based on the features of target data
  weighter = DensityRatioWeighter(targetdata(problem),
                                  variables=features(task(problem)),
                                  estimator=eestimator.dre,
                                  optlib=eestimator.optlib)
  wcv = WeightedCrossValidation(weigther, eestimator.k, shuffle=true)
  error(solve, problem, wcv)
end

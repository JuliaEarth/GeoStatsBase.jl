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
  DΩt  = targetdata(problem)
  vars = collect(features(task(problem)))
  weighter = DensityRatioWeighter(DΩt, variables=vars,
                                  estimator=eestimator.dre,
                                  optlib=eestimator.optlib)
  wcv = WeightedCrossValidation(weighter, eestimator.k, shuffle=true)
  error(solver, problem, wcv)
end

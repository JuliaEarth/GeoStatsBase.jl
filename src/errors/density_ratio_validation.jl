# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioValidation(k; [parameters])

Desntity ratio validation where weights are first obtained with density
ratio estimation, and then used in `k`-fold weighted cross-validation.

## Parameters

* `estimator` - Density ratio estimator (default to `LSIF()`)
* `optlib`    - Optimization library (default to `default_optlib(estimator)`)
* `lambda`    - Power of density ratios (default to `1.0`)

Please see [DensityRatioEstimation.jl]
(https://github.com/JuliaEarth/DensityRatioEstimation.jl)
for a list of supported estimators.

## References

* TODO
"""
struct DensityRatioValidation{T,E,O} <: ErrorEstimationMethod
  k::Int
  lambda::T
  dre::E
  optlib::O
  loss::Dict{Symbol,SupervisedLoss}
end

function DensityRatioValidation(k::Int; lambda=1.0, loss=Dict(),
                                estimator=LSIF(), optlib=default_optlib(estimator))
  @assert k > 0 "number of folds must be positive"
  @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
  T = typeof(lambda)
  E = typeof(estimator)
  O = typeof(optlib)
  DensityRatioValidation{T,E,O}(k, lambda, estimator, optlib, loss)
end

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::DensityRatioValidation)
  # weight samples based on the features of target data
  tdata = targetdata(problem)
  vars = collect(features(task(problem)))
  weighter = DensityRatioWeighter(tdata, vars,
                                  estimator=method.dre,
                                  optlib=method.optlib)
  wcv = WeightedCrossValidation(weighter,
                                method.k, shuffle=true,
                                lambda=method.lambda,
                                loss=method.loss)
  error(solver, problem, wcv)
end

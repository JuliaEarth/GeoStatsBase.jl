# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioValidation(k; [parameters])

Desntity ratio validation where weights are first obtained with density
ratio estimation, and then used in `k`-fold weighted cross-validation.

## Parameters

* `shuffle`   - Shuffle the data before folding (default to `true`)
* `estimator` - Density ratio estimator (default to `LSIF()`)
* `optlib`    - Optimization library (default to `default_optlib(estimator)`)
* `lambda`    - Power of density ratios (default to `1.0`)

Please see [DensityRatioEstimation.jl]
(https://github.com/JuliaEarth/DensityRatioEstimation.jl)
for a list of supported estimators.

## References

* Hoffimann et al. 2020. [Geostatistical Learning: Challenges and Opportunities]
  (TODO-LINK)
"""
struct DensityRatioValidation{T,E,O} <: ErrorEstimationMethod
  k::Int
  shuffle::Bool
  lambda::T
  dre::E
  optlib::O
  loss::Dict{Symbol,SupervisedLoss}
end

function DensityRatioValidation(k::Int; shuffle=true, lambda=1.0, loss=Dict(),
                                estimator=LSIF(), optlib=default_optlib(estimator))
  @assert k > 0 "number of folds must be positive"
  @assert 0 ≤ lambda ≤ 1 "lambda must lie in [0,1]"
  T = typeof(lambda)
  E = typeof(estimator)
  O = typeof(optlib)
  DensityRatioValidation{T,E,O}(k, shuffle, lambda, estimator, optlib, loss)
end

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::DensityRatioValidation)
  tdata = targetdata(problem)
  vars = collect(features(task(problem)))

  # density-ratio weights
  weighting = DensityRatioWeighting(tdata, vars,
                                    estimator=method.dre,
                                    optlib=method.optlib)

  # random folds
  folding = RandomFolding(method.k, method.shuffle)

  wcv = WeightedCrossValidation(weighting, folding,
                                lambda=method.lambda,
                                loss=method.loss)

  error(solver, problem, wcv)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CrossValidation(k; shuffle=true, loss=Dict())

`k`-fold cross-validation. Optionally, `shuffle` the
data, and specify `loss` function  from `LossFunctions.jl`
for some of the variables.

## References

* Geisser, S. 1975. [The predictive sample reuse method with applications]
  (https://www.jstor.org/stable/2285815)
* Burman, P. 1989. [A comparative study of ordinary cross-validation, v-fold
  cross-validation and the repeated learning-testing methods]
  (https://www.jstor.org/stable/2336116)
"""
struct CrossValidation <: ErrorEstimationMethod
  k::Int
  shuffle::Bool
  loss::Dict{Symbol,SupervisedLoss}
end

CrossValidation(k::Int; shuffle=true, loss=Dict()) =
  CrossValidation(k, shuffle, loss)

function Base.error(solver, problem, method::CrossValidation)
  # uniform weights
  weighting = UniformWeighting()

  # random folds
  folding = RandomFolding(method.k, method.shuffle)

  wcv = WeightedCrossValidation(weighting, folding,
                                lambda=1, loss=method.loss)

  error(solver, problem, wcv)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LeaveOneOut(; loss=Dict())

Leave-one-out validation. Optionally, specify `loss` function
from `LossFunctions.jl` for some of the variables.

## References

* Stone. 1974. [Cross-Validatory Choice and Assessment of Statistical Predictions]
  (https://rss.onlinelibrary.wiley.com/doi/abs/10.1111/j.2517-6161.1974.tb00994.x)
"""
struct LeaveOneOut <: ErrorEstimationMethod
  loss::Dict{Symbol,SupervisedLoss}
end

LeaveOneOut(; loss=Dict()) = LeaveOneOut(loss)

function Base.error(solver, problem, method::LeaveOneOut)
  # uniform weights
  weighting = UniformWeighting()

  # point folds
  folding = OneFolding()

  wcv = WeightedValidation(weighting, folding,
                           lambda=1, loss=method.loss)

  error(solver, problem, wcv)
end

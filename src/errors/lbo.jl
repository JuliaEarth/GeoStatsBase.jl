# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LeaveBallOut(ball; loss=Dict())

Leave-`ball`-out (a.k.a. spatial leave-one-out) validation.
Optionally, specify `loss` function from `LossFunctions.jl`
for some of the variables.

    LeaveBallOut(radius; loss=Dict())

By default, use Euclidean ball of given `radius` in space.

## References

* Le Rest et al. 2014. [Spatial leave-one-out cross-validation
  for variable selection in the presence of spatial autocorrelation]
  (https://onlinelibrary.wiley.com/doi/full/10.1111/geb.12161)
"""
struct LeaveBallOut{B<:BallNeighborhood} <: ErrorEstimationMethod
  ball::B
  loss::Dict{Symbol,SupervisedLoss}
end

LeaveBallOut(ball::BallNeighborhood; loss=Dict()) =
  LeaveBallOut{typeof(ball)}(ball, loss)

LeaveBallOut(radius::Number; loss=Dict()) =
  LeaveBallOut(BallNeighborhood(radius), loss=loss)

function error(solver, problem, method::LeaveBallOut)
  # uniform weights
  weighting = UniformWeighting()

  # ball folds
  folding = BallFolding(method.ball)

  wcv = WeightedCrossValidation(weighting, folding,
                                lambda=1, loss=method.loss)

  error(solver, problem, wcv)
end

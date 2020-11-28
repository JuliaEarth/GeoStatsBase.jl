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

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::LeaveBallOut)
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  ball  = method.ball
  loss  = method.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # folds for cross-validation
  fs = folds(sdata, BallFolding(ball))

  # error for a fold
  function ε(f)
    # source and target data
    source = view(sdata, first(f))
    target = view(sdata, last(f))

    # setup and solve sub-problem
    subproblem = LearningProblem(source, target, task(problem))
    solution   = solve(subproblem, solver)

    # loss for each variable
    losses = map(ovars) do var
      y = target[var][1]
      ŷ = solution[var][1]
      var => value(loss[var], y, ŷ)
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), fs)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

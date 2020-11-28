# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockCrossValidation(sides; loss=Dict())

Cross-validation with blocks of given `sides`. Optionally,
specify `loss` function from `LossFunctions.jl` for some
of the variables. If only one side is provided, then blocks
become cubes.

## References

* Roberts et al. 2017. [Cross-validation strategies for data with
  temporal, spatial, hierarchical, or phylogenetic structure]
  (https://onlinelibrary.wiley.com/doi/10.1111/ecog.02881)
* Pohjankukka et al. 2017. [Estimating the prediction performance
  of spatial models via spatial k-fold cross-validation]
  (https://www.tandfonline.com/doi/full/10.1080/13658816.2017.1346255)
"""
struct BlockCrossValidation{S} <: ErrorEstimationMethod
  sides::S
  loss::Dict{Symbol,SupervisedLoss}
end

BlockCrossValidation(sides; loss=Dict()) =
  BlockCrossValidation{typeof(sides)}(sides, loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::BlockCrossValidation)
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  sides = method.sides
  loss  = method.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # folds for cross-validation
  bsides = length(sides) > 1 ? sides : ntuple(i->sides, ncoords(sdata))
  fs = folds(sdata, BlockFolding(bsides))

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
      y = target[var]
      ŷ = solution[var]
      ℒ = value(loss[var], y, ŷ, AggMode.Mean())
      var => ℒ
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), fs)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

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
  loss  = method.loss
  sides = method.sides
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  bsides    = length(sides) > 1 ? sides : ntuple(i->sides, ncoords(sdata))
  blocks    = partition(sdata, BlockPartitioner(bsides))
  neighbors = metadata(blocks)[:neighbors]
  bsubsets  = subsets(blocks)
  allblocks = 1:length(blocks)

  # error for a block b
  function ε(b)
    # source and target blocks
    sblocks = setdiff(allblocks, [neighbors[b]; b])
    tblocks = [b]

    # source and target indices
    sinds = reduce(vcat, bsubsets[sblocks])
    tinds = reduce(vcat, bsubsets[tblocks])

    # source and target data
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = LearningProblem(train, hold, task(problem))
    solution   = solve(subproblem, solver)

    # loss for each variable
    losses = map(ovars) do var
      y = hold[var]
      ŷ = solution[var]
      ℒ = value(loss[var], y, ŷ, AggMode.Mean())
      var => ℒ
    end

    Dict(losses)
  end

  # compute error for each fold in parallel
  εs = foldxt(vcat, Map(ε), allblocks)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

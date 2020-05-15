# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockCrossValidation(sides; loss=Dict())

Cross-validation with blocks of given `sides`. Optionally,
specify `loss` function from `LossFunctions.jl` for some
of the variables. If only one side is provided, then blocks
become cubes.

## References

* Roberts et al. 2017. Cross-validation strategies for data with
  temporal, spatial, hierarchical, or phylogenetic structure.
"""
struct BlockCrossValidation{S} <: AbstractErrorEstimator
  sides::S
  loss::Dict{Symbol,SupervisedLoss}
end

BlockCrossValidation(sides; loss=Dict()) =
  BlockCrossValidation{typeof(sides)}(sides, loss)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::BlockCrossValidation)
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  loss  = eestimator.loss
  sides = eestimator.sides
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[1,var])
    end
  end

  bsides    = length(sides) > 1 ? sides : ntuple(i->sides, ndims(sdata))
  blocks    = partition(sdata, BlockPartitioner(bsides))
  bsubsets  = subsets(blocks)
  neighbors = blocks[:neighbors]
  allblocks = 1:length(blocks)

  solutions = pmap(allblocks) do b
    # source and target blocks
    sblocks = setdiff(allblocks, vcat(neighbors[b], b))
    tblocks = [b]

    # source and target indices
    sinds = reduce(vcat, bsubsets[sblocks])
    tinds = reduce(vcat, bsubsets[tblocks])

    # setup and solve learning sub-problem
    subproblem = LearningProblem(view(sdata, sinds),
                                 view(sdata, tinds),
                                 task(problem))
    solve(subproblem, solver)
  end

  result = pmap(ovars) do var
    losses = map(allblocks) do b
      dview = view(sdata, bsubsets[b])
      y = dview[var]
      ŷ = solutions[b][var]
      value(loss[var], y, ŷ, AggMode.Mean())
    end
    var => mean(losses)
  end

  Dict(result)
end

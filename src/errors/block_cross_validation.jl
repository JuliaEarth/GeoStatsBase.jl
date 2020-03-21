# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockCrossValidation(side; loss=Dict())

Cross-validation with blocks of given `side`. Optionally,
specify `loss` function from `LossFunctions.jl` for some
of the variables.

## References

* Roberts et al. 2017. Cross-validation strategies for data with
  temporal, spatial, hierarchical, or phylogenetic structure.
"""
struct BlockCrossValidation{T<:Real} <: AbstractErrorEstimator
  side::T
  loss::Dict{Symbol,SupervisedLoss}
end

BlockCrossValidation(side::Real; loss=Dict()) =
  BlockCrossValidation{typeof(side)}(side, loss)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::BlockCrossValidation)
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  side  = eestimator.side
  loss  = eestimator.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[1,var])
    end
  end

  blocks    = partition(sdata, BlockPartitioner(side))
  bsubsets  = subsets(blocks)
  neighbors = metadata(blocks)[:neighbors]
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

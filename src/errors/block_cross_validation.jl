# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    BlockCrossValidation(side)

Cross-validation with blocks of given `side`.

## References

* Roberts et al. 2017. Cross-validation strategies for data with
  temporal, spatial, hierarchical, or phylogenetic structure.
"""
struct BlockCrossValidation{T<:Real} <: AbstractErrorEstimator
  side::T
end

function estimate_error(solver::AbstractLearningSolver,
                        problem::LearningProblem,
                        eestimator::BlockCrossValidation)
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  side  = eestimator.side

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
      ŷ = solutions[b][var]
      y = dview[var]
      mean((ŷ .- y).^2)
    end
    var => mean(losses)
  end

  Dict(result)
end

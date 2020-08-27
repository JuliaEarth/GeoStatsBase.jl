# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CrossValidation(k; shuffle=true, loss=Dict())

`k`-fold cross-validation. Optionally, `shuffle` the
data, and specify `loss` function  from `LossFunctions.jl`
for some of the variables.

    CrossValidation(partitioner; loss=Dict())

Generalization of k-fold cross-validation in which
the data is split using `partitioner`.

## References

* Geisser, S. 1975. [The predictive sample reuse method with applications]
  (https://www.jstor.org/stable/2285815)
* Burman, P. 1989. [A comparative study of ordinary cross-validation, v-fold
  cross-validation and the repeated learning-testing methods]
  (https://www.jstor.org/stable/2336116)
"""
struct CrossValidation{P<:AbstractPartitioner} <: AbstractErrorEstimator
  partitioner::P
  loss::Dict{Symbol,SupervisedLoss}
end

CrossValidation(partitioner::AbstractPartitioner; loss=Dict()) =
  CrossValidation{typeof(partitioner)}(partitioner, loss)

CrossValidation(k::Int; shuffle=true, loss=Dict()) =
  CrossValidation(UniformPartitioner(k, shuffle), loss=loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               eestimator::CrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  partitioner = eestimator.partitioner
  loss  = eestimator.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # folds for cross-validation
  folds  = subsets(partition(sdata, partitioner))
  nfolds = length(folds)

  solutions = map(1:nfolds) do k
    # source and target indices
    sinds = [ind for i in vcat(1:k-1, k+1:nfolds) for ind in folds[i]]
    tinds = folds[k]

    # source and target data
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = LearningProblem(train, hold, task(problem))
    solve(subproblem, solver)
  end

  result = map(ovars) do var
    losses = map(1:nfolds) do k
      hold = view(sdata, folds[k])
      y = hold[var]
      ŷ = solutions[k][var]
      value(loss[var], y, ŷ, AggMode.Mean())
    end
    var => mean(losses)
  end

  Dict(result)
end

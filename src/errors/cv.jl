# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
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
struct CrossValidation{P<:PartitionMethod} <: ErrorEstimationMethod
  partitioner::P
  loss::Dict{Symbol,SupervisedLoss}
end

CrossValidation(partitioner::PartitionMethod; loss=Dict()) =
  CrossValidation{typeof(partitioner)}(partitioner, loss)

CrossValidation(k::Int; shuffle=true, loss=Dict()) =
  CrossValidation(RandomPartition(k, shuffle), loss=loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::CrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  partitioner = method.partitioner
  loss  = method.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # folds for cross-validation
  folds  = subsets(partition(sdata, partitioner))
  nfolds = length(folds)

  # error for a fold k
  function ε(k)
    # source and target indices
    sinds = [ind for i in [1:k-1; k+1:nfolds] for ind in folds[i]]
    tinds = folds[k]

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
  εs = foldxt(vcat, Map(ε), 1:nfolds)

  # combine error from different folds
  Dict(var => mean(get.(εs, var, 0)) for var in ovars)
end

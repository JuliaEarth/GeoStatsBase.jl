# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CrossValidation(k; shuffle=true, loss=Dict())

`k`-fold cross-validation. Optionally, `shuffle` the
data, and specify `loss` function  from `LossFunctions.jl`
for some of the variables.

## References

* Geisser, S. 1975. [The predictive sample reuse method with applications]
  (https://www.jstor.org/stable/2285815)
* Burman, P. 1989. [A comparative study of ordinary cross-validation, v-fold
  cross-validation and the repeated learning-testing methods]
  (https://www.jstor.org/stable/2336116)
"""
struct CrossValidation <: ErrorEstimationMethod
  k::Int
  shuffle::Bool
  loss::Dict{Symbol,SupervisedLoss}
end

CrossValidation(k::Int; shuffle=true, loss=Dict()) =
  CrossValidation(k, shuffle, loss)

function error(solver::AbstractLearningSolver,
               problem::LearningProblem,
               method::CrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  nfolds  = method.k
  shuffle = method.shuffle
  loss    = method.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[var][1])
    end
  end

  # folds for cross-validation
  fs = folds(sdata, RandomFolding(nfolds, shuffle))

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

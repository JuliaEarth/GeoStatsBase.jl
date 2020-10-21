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

function error(solver::AbstractSolver,
               problem::AbstractProblem,
               eestimator::CrossValidation)

  @assert !isa(problem, SimulationProblem) "not available for SimulationProblem"
  # problem info
  probtype = typeof(problem)
  EP = probtype <: EstimationProblem ? true : false
  sdata = EP ? data(problem) : sourcedata(problem)
  ovars = EP ? [v for (v,V) in variables(problem)] : outputvars(task(problem))

  # retrieve problem info
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
  probcall = getfield(Main, nameof(probtype))
  thirdarg = EP ? Tuple(ovars) : task(problem)

  # error for a fold k
  function ε(k)
    # source and target indices
    sinds = [ind for i in [1:k-1; k+1:nfolds] for ind in folds[i]]
    tinds = folds[k]

    # source and target data
    train = view(sdata, sinds)
    hold  = view(sdata, tinds)

    # setup and solve sub-problem
    subproblem = probcall(train, hold, thirdarg)
    solution   = solve(subproblem, solver)

    # loss for each variable
    losses = map(ovars) do var
      y = hold[var]
      ŷ = EP ? solution[var].mean : solution[var]
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

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

* Hastie et al. 2001. The Elements of Statistical Learning.
"""
struct CrossValidation{P<:AbstractPartitioner} <: AbstractErrorEstimator
  partitioner::P
  loss::Dict{Symbol,SupervisedLoss}
end

CrossValidation(partitioner::AbstractPartitioner; loss=Dict()) =
  CrossValidation{typeof(partitioner)}(partitioner, loss)

CrossValidation(k::Int; shuffle=true, loss=Dict()) =
  CrossValidation(UniformPartitioner(k, shuffle), loss=loss)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::CrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  partitioner = eestimator.partitioner
  loss  = eestimator.loss
  for var in ovars
    if var ∉ keys(loss)
      loss[var] = defaultloss(sdata[1,var])
    end
  end

  # folds for cross-validation
  folds  = subsets(partition(sdata, partitioner))
  nfolds = length(folds)

  solutions = pmap(1:nfolds) do k
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

  result = pmap(ovars) do var
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

function Base.error(solver::AbstractEstimationSolver,
                    problem::EstimationProblem,
                    eestimator::CrossValidation)
  # retrieve problem info
  pdata = data(problem)
  pdomain = domain(problem)
  partitioner = eestimator.partitioner

  # folds for cross-validation
  folds  = subsets(partition(pdata, partitioner))
  nfolds = length(folds)

  result = []
  for (var, V) in variables(problem)
    # mappings from data to domain locations
    varmap = Dict(datloc => domloc for (domloc, datloc) in datamap(problem, var))

    # k-fold validation loop
    losses = pmap(1:nfolds) do k
      # training and holdout set
      train = [ind for i in vcat(1:k-1, k+1:nfolds) for ind in folds[i]]
      hold  = folds[k]

      # discard indices that were filtered out by mapping strategy (e.g. missing values)
      train = filter(in(keys(varmap)), train)
      hold  = filter(in(keys(varmap)), hold)

      if isempty(train)
        missing
      else
        # copy data to their locations in domain
        mapper = CopyMapper([varmap[ind] for ind in train])

        # setup and solve sub-problem
        subproblem = EstimationProblem(view(pdata, train), pdomain,
                                       var, mapper=mapper)
        solution = solve(subproblem, solver)

        # get true holdout values
        y = pdata[hold,var]

        # get solver estimate at holdout locations
        μ, _ = solution[var]
        ŷ = [μ[varmap[loc]] for loc in hold]

        # loss for fold
        mean((ŷ .- y).^2)
      end
    end

    push!(result, var => mean(skipmissing(losses)))
  end

  Dict(result)
end

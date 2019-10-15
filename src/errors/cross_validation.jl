# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CrossValidation(k, [shuffle])

Compare estimation solvers using k-fold cross-validation.
Optionally shuffle the data (default to true).

    CrossValidation(partitioner)

Compare estimation solvers using cross-validation by
splitting the data with a `partitioner`. This method
is a generalization of k-fold cross-validation, which
uses a [`UniformPartitioner`](@ref) to split the data.

The result of the comparison stores the errors for each
variable of the problem.

## Examples

Compare `solver₁` and `solver₂` on a `problem` with variable
`:var` using 10 folds. Plot error distribution:

```julia
julia> result = compare([solver₁, solver₂], problem, CrossValidation(10))
julia> plot(result, bins=50)
```
"""
struct CrossValidation{P} <: AbstractErrorEstimator
  partitioner::P
end

CrossValidation(k::Int, shuffle::Bool) =
  CrossValidation(UniformPartitioner(k, shuffle))
CrossValidation(k::Int) = CrossValidation(k, true)
CrossValidation() = CrossValidation(10)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::CrossValidation)
  # retrieve problem info
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  partitioner = eestimator.partitioner

  # folds for cross-validation
  folds  = subsets(partition(sdata, partitioner))
  nfolds = length(folds)

  solutions = pmap(1:nfolds) do k
    # source and target indices
    sinds = [ind for i in vcat(1:k-1, k+1:nfolds) for ind in folds[i]]
    tinds = folds[k]

    # setup and solve sub-problem
    subproblem = LearningProblem(view(sdata, sinds),
                                 view(sdata, tinds),
                                 task(problem))
    solve(subproblem, solver)
  end

  result = pmap(ovars) do var
    𝔏 = defaultloss(sdata[1,var])
    losses = map(1:nfolds) do k
      dview = view(sdata, folds[k])
      ŷ = solutions[k][var]
      y = dview[var]
      𝔏(ŷ, y)
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
      # holdout set
      hold = folds[k]

      # training set
      train = [ind for i in vcat(1:k-1, k+1:nfolds) for ind in folds[i]]

      # discard indices that were filtered out by mapping strategy (e.g. missing values)
      hold  = filter(in(keys(varmap)), hold)
      train = filter(in(keys(varmap)), train)

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

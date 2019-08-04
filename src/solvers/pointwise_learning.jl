# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    PointwiseLearn(models)

A learning solver that converts spatial data to a tabular format
with features (and possibly labels) for each point, and then solves
the problem with statistical learning `models`.

## Parameters

* `models` - Learning models (e.g. SVM, Logistic Regression, K-means)

## Notes

Any model implementing the `MLJBase` interface can be used in
pointwise learning. Please refer to the `MLJ` documentation for
a list of available models.
"""
struct PointwiseLearn
  models::Vector{MLJBase.Model}
end

PointwiseLearn(model::MLJBase.Model) = PointwiseLearn([model])

function solve(problem::LearningProblem, solver::PointwiseLearn)
  ptasks = tasks(problem)
  models = solver.models

  @assert length(ptasks) == length(models) "please specify a learning model for each task"

  results = []

  for (task, model) in zip(ptasks, models)
    # assert model is compatible with task
    @assert iscompatible(model, task) "$model is not compatible with $task"

    # learn model on source data
    lmodel = learn(task, sourcedata(problem), model)

    # apply model to target data
    result = perform(task, targetdata(problem), lmodel)

    push!(results, result)
  end

  dict = reduce(merge, results)

  LearningSolution(domain(targetdata(problem)), dict)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solver::PointwiseLearn)
  print(io, "PointwiseLearn")
end

function Base.show(io::IO, ::MIME"text/plain", solver::PointwiseLearn)
  println(io, solver)
  println(io, "  models")
  for model in solver.models
    print(io, "    └─")
    show(IOContext(io, :compact => true), model)
    println(io, "")
  end
end

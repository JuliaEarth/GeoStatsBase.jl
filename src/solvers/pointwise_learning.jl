# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    PointwiseLearn(model)

A learning solver that converts spatial data to a tabular format
with features (and possibly labels) for each point, and then solves
the problem with a statistical learning `model`.

## Parameters

* `model` - Learning model (e.g. SVM, Logistic Regression, K-means)

## Notes

Any model implementing the `MLJBase` interface can be used in
pointwise learning. Please refer to the `MLJ` documentation for
a list of available models.
"""
struct PointwiseLearn{M<:MLJBase.Model}
  model::M
end

function solve(problem::LearningProblem, solver::PointwiseLearn)
  # TODO: assert model is compatible with task
  # https://github.com/alan-turing-institute/MLJ.jl/issues/191

  # learn model on source data
  lmodel = learn(task(problem), sourcedata(problem), solver.model)

  # apply model to target data
  result = perform(task(problem), targetdata(problem), lmodel)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solver::PointwiseLearn)
  print(io, "PointwiseLearn")
end

function Base.show(io::IO, ::MIME"text/plain", solver::PointwiseLearn)
  println(io, solver)
  print(io, "  └─model ⇨ ")
  show(IOContext(io, :compact => true), solver.model)
end

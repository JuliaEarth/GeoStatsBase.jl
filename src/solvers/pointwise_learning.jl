# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PointwiseLearn(model)

A learning solver that converts spatial data to a tabular format
with features (and possibly labels) for each point, and then solves
the problem with statistical learning `model`.

## Parameters

* `model` - Learning model (e.g. SVM, Logistic Regression, K-means)

## Notes

Any model implementing the `MLJModelInterface.jl` can be used in
pointwise learning. Please refer to the `MLJ` documentation for
a list of available models.
"""
struct PointwiseLearn{M} <: AbstractLearningSolver
  model::M
end

function solve(problem::LearningProblem, solver::PointwiseLearn)
  sdata = sourcedata(problem)
  tdata = targetdata(problem)
  ptask = task(problem)
  model = solver.model

  # assert model is compatible with task
  @assert iscompatible(model, ptask) "$model is not compatible with $ptask"

  # learn model on source data
  lmodel = learn(ptask, sdata, model)

  # apply model to target data
  perform(ptask, tdata, lmodel)
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
  println(io, "")
end

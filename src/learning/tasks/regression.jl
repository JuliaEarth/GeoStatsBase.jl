# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RegressionTask(x, y)

A regression task consists of finding a function `f` such that `y ~ f(x)`
for all training examples `(x,y)` with `y` a continuous variable.
"""
struct RegressionTask{N} <: AbstractLearningTask
  features::NTuple{N,Symbol}
  label::Symbol
end

RegressionTask(x::Symbol, y::Symbol) = RegressionTask{1}((x,), y)

RegressionTask(x::AbstractVector{Symbol}, y::Symbol) =
  RegressionTask{length(x)}(Tuple(x), y)

"""
    features(task)

Return the features of the regression `task`.
"""
features(task::RegressionTask) = task.features

"""
    label(task)

Return the label of the regression `task`.
"""
label(task::RegressionTask) = task.label

issupervised(task::RegressionTask) = true

# ------------
# IO methods
# ------------
function Base.show(io::IO, task::RegressionTask)
  x = task.features
  y = task.label
  lhs = length(x) > 1 ? "("*join(x, ", ")*")" : "$(x[1])"
  print(io, "Regression $lhs → $y")
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    RegressionTask(x, y)

A regression task consists of finding a function `f` such that `y ~ f(x)`
for all training examples `(x,y)` with `y` a continuous variable.
"""
struct RegressionTask{N} <: SupervisedLearningTask
  features::NTuple{N,Symbol}
  label::Symbol
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, task::RegressionTask)
  x = join(features(task), ", ")
  y = label(task)
  print(io, "Regression ($x) → $y")
end

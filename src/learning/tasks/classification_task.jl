# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    ClassificationTask(x, y)

A classification task consists of finding a function `f` such that `y ~ f(x)`
for all training examples `(x,y)` with `y` a categorical variable.
"""
struct ClassificationTask{N} <: SupervisedLearningTask
  features::NTuple{N,Symbol}
  label::Symbol
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, task::ClassificationTask)
  x = features(task)
  y = label(task)
  lhs = length(x) > 1 ? "("*join(x, ", ")*")" : "$(x[1])"
  print(io, "Classification $lhs → $y")
end

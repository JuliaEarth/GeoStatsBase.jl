# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    ClassificationTask(x, y)

A classification task consists of finding a function `f` such that `y ~ f(x)`
for all training examples `(x,y)` with `y` a categorical variable.
"""
struct ClassificationTask{N} <: AbstractLearningTask
  features::NTuple{N,Symbol}
  label::Symbol
end

ClassificationTask(x::Symbol, y::Symbol) = ClassificationTask{1}((x,), y)

ClassificationTask(x::AbstractVector{Symbol}, y::Symbol) =
  ClassificationTask{length(x)}(Tuple(x), y)

issupervised(task::ClassificationTask) = true

"""
    features(task)

Return the features of the classification `task`.
"""
features(task::ClassificationTask) = task.features

"""
    label(task)

Return the label of the classification `task`.
"""
label(task::ClassificationTask) = task.label

# ------------
# IO methods
# ------------
function Base.show(io::IO, task::ClassificationTask)
  x = task.features
  y = task.label
  lhs = length(x) > 1 ? "("*join(x, ", ")*")" : "$(x[1])"
  print(io, "Classification $lhs → $y")
end

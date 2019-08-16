# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    ClusteringTask(x, y)

A clustering task consists of grouping training examples based on
features `x ∈ Rⁿ`. The resulting clusters are saved in spatial
variable `y`.
"""
struct ClusteringTask{N} <: AbstractLearningTask
  features::NTuple{N,Symbol}
  output::Symbol
end

ClusteringTask(x::Symbol, out::Symbol) = ClusteringTask{1}((x,), out)

ClusteringTask(x::AbstractVector{Symbol}, out::Symbol) =
  ClusteringTask{length(x)}(Tuple(x), out)

"""
    features(task)

Return the features of the clustering `task`.
"""
features(task::ClusteringTask) = task.features

outputvars(task::ClusteringTask) = (task.output,)

# ------------
# IO methods
# ------------
function Base.show(io::IO, task::ClusteringTask)
  x = task.features
  y = task.output
  lhs = length(x) > 1 ? "("*join(x, ", ")*")" : "$(x[1])"
  print(io, "Clustering $lhs → $y")
end

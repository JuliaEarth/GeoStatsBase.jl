# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    ClusteringTask(x)

A clustering task consists of grouping training examples based on features `x ∈ Rⁿ`.
"""
struct ClusteringTask{N} <: UnsupervisedLearningTask
  features::NTuple{N,Symbol}
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, task::ClusteringTask)
  x = join(features(task), ", ")
  print(io, "Clustering ($x)")
end

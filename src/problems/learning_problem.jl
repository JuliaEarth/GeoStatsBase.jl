# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearningProblem(sourcedata, targetdata, task)

A spatial learning problem with `sourcedata`, `targetdata`,
and learning `task`.

## Examples

Create a clustering problem based on a set of soil features:

```julia
julia> LearningProblem(sourcedata, targetdata,
                       ClusteringTask((:moisture,:mineral)))
```
"""
struct LearningProblem{DΩₛ<:AbstractData,
                       DΩₜ<:AbstractData,
                       T<:AbstractLearningTask} <: AbstractProblem
  sourcedata::DΩₛ
  targetdata::DΩₜ
  task::T

  function LearningProblem{DΩₛ,DΩₜ,T}(sourcedata, targetdata,
                                      task) where {DΩₛ<:AbstractData,
                                                   DΩₜ<:AbstractData,
                                                   T<:AbstractLearningTask}
    sourcevars = keys(variables(sourcedata))
    targetvars = keys(variables(targetdata))

    # assert spatial configuration
    @assert ndims(sourcedata) == ndims(targetdata) "source and target data must have the same number of dimensions"
    @assert coordtype(sourcedata) == coordtype(targetdata) "source and target data must have the same coordinate type"

    # assert task is compatible with the data
    if iscomposite(task)
      # TODO
    else
      @assert features(task) ⊆ sourcevars "features must be present in source data"
      @assert features(task) ⊆ targetvars "features must be present in target data"
      if issupervised(task)
        @assert label(task) ∈ sourcevars "label must be present in source data"
      end
    end

    new(sourcedata, targetdata, task)
  end
end

LearningProblem(sdata::DΩₛ, tdata::DΩₜ, task::T) where {DΩₛ<:AbstractData,
                                                        DΩₜ<:AbstractData,
                                                        T<:AbstractLearningTask} =
  LearningProblem{DΩₛ,DΩₜ,T}(sdata, tdata, task)

"""
    sourcedata(problem)

Return the source data of the learning `problem`.
"""
sourcedata(problem::LearningProblem) = problem.sourcedata

"""
    targetdata(problem)

Return the target data of the learning `problem`.
"""
targetdata(problem::LearningProblem) = problem.targetdata

"""
    task(problem)

Return the learning task of the learning `problem`.
"""
task(problem::LearningProblem) = problem.task

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::LearningProblem)
  dim = ndims(problem.sourcedata)
  print(io, "$(dim)D LearningProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::LearningProblem)
  println(io, problem)
  println(io, "  source")
  println(io, "    └─data: ", problem.sourcedata)
  println(io, "  target")
  println(io, "    └─data: ", problem.targetdata)
  println(io, "  task: ", problem.task)
end

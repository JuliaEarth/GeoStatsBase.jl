# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
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

  function LearningProblem{DΩₛ,DΩₜ,T}(sourcedata, targetdata, task) where {DΩₛ<:AbstractData,
                                                                           DΩₜ<:AbstractData,
                                                                           T<:AbstractLearningTask}
    sourcevars = keys(variables(sourcedata))
    targetvars = keys(variables(targetdata))

    # assert spatial configuration
    @assert ndims(sourcedata) == ndims(targetdata) "source and target data must have the same number of dimensions"
    @assert coordtype(sourcedata) == coordtype(targetdata) "source and target data must have the same coordinate type"

    # assert that tasks are valid for the data
    @assert features(task) ⊆ sourcevars ⊆ targetvars "features must be present in data"
    if task isa SupervisedLearningTask
      @assert label(task) ∈ sourcevars "label must be present in source data"
    end

    new(sourcedata, targetdata, task)
  end
end

function LearningProblem(sourcedata::DΩₛ, targetdata::DΩₜ, task::T) where {DΩₛ<:AbstractData,
                                                                           DΩₜ<:AbstractData,
                                                                           T<:AbstractLearningTask}
  LearningProblem{DΩₛ,DΩₜ,T}(sourcedata, targetdata, task)
end

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
  println(io, "    └─data:   ", problem.sourcedata)
  println(io, "  target")
  println(io, "    └─data:   ", problem.targetdata)
  print(  io, "  task: ", problem.task)
end

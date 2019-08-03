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
struct LearningProblem{DΩₛ<:AbstractData,DΩₜ<:AbstractData} <: AbstractProblem
  sourcedata::DΩₛ
  targetdata::DΩₜ
  tasks::Vector{AbstractLearningTask}

  function LearningProblem{DΩₛ,DΩₜ}(sourcedata, targetdata, tasks) where {DΩₛ<:AbstractData,
                                                                          DΩₜ<:AbstractData}
    sourcevars = keys(variables(sourcedata))
    targetvars = keys(variables(targetdata))

    # assert spatial configuration
    @assert ndims(sourcedata) == ndims(targetdata) "source and target data must have the same number of dimensions"
    @assert coordtype(sourcedata) == coordtype(targetdata) "source and target data must have the same coordinate type"

    # assert that tasks are valid for the data
    for task in tasks
      @assert features(task) ⊆ sourcevars "features must be present in source data"
      @assert features(task) ⊆ targetvars "features must be present in target data"
      if issupervised(task)
        @assert label(task) ∈ sourcevars "label must be present in source data"
      end
    end

    new(sourcedata, targetdata, tasks)
  end
end

LearningProblem(sourcedata::DΩₛ, targetdata::DΩₜ,
                tasks::AbstractVector) where {DΩₛ<:AbstractData,
                                              DΩₜ<:AbstractData} =
  LearningProblem{DΩₛ,DΩₜ}(sourcedata, targetdata, tasks)

LearningProblem(sourcedata::DΩₛ, targetdata::DΩₜ,
                task::AbstractLearningTask) where {DΩₛ<:AbstractData,
                                                   DΩₜ<:AbstractData} =
  LearningProblem(sourcedata, targetdata, [task])

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
    tasks(problem)

Return the learning tasks of the learning `problem`.
"""
tasks(problem::LearningProblem) = problem.tasks

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
  println(io, "  tasks")
  for task in problem.tasks
    println(io, "    └─", task)
  end
end

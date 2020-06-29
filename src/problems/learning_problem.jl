# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearningProblem(sdata, tdata, task)

A spatial learning problem with source data `sdata`,
target data `tdata`, and learning `task`.

## Examples

Create a clustering problem based on a set of soil features:

```julia
julia> LearningProblem(sdata, tdata,
                       ClusteringTask((:moisture,:mineral)))
```
"""
struct LearningProblem{DΩₛ<:AbstractData,
                       DΩₜ<:AbstractData,
                       T<:AbstractLearningTask} <: AbstractProblem
  sdata::DΩₛ
  tdata::DΩₜ
  task::T

  function LearningProblem{DΩₛ,DΩₜ,T}(sdata, tdata, task) where {DΩₛ<:AbstractData,
                                                                 DΩₜ<:AbstractData,
                                                                 T<:AbstractLearningTask}
    sourcevars = keys(variables(sdata))
    targetvars = keys(variables(tdata))

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

    new(sdata, tdata, task)
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
sourcedata(problem::LearningProblem) = problem.sdata

"""
    targetdata(problem)

Return the target data of the learning `problem`.
"""
targetdata(problem::LearningProblem) = problem.tdata

"""
    task(problem)

Return the learning task of the learning `problem`.
"""
task(problem::LearningProblem) = problem.task

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::LearningProblem)
  dim = ndims(problem.sdata)
  print(io, "$(dim)D LearningProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::LearningProblem)
  println(io, problem)
  println(io, "  source: ", problem.sdata)
  println(io, "  target: ", problem.tdata)
  print(  io, "  task:   ", problem.task)
end

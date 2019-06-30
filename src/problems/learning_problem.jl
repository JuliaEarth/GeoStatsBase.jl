# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    LearningProblem(sourcedata, targetdata => targetdomain, task)

A spatial learning problem with source data `sourcedata`, target
data `targetdata`, target domain `targetdomain`, and learning `task`.

## Examples

Create a clustering problem based on a set of soil features:

```julia
julia> LearningProblem(sourcedata, targetdata => targetdomain,
                       ClusteringTask((:moisture,:mineral,:planttype)))
```
"""
struct LearningProblem{Sₛ<:AbstractData,
                       Sₜ<:AbstractData,
                       Dₜ<:AbstractDomain,
                       T<:AbstractLearningTask,
                       M<:AbstractMapper} <: AbstractProblem
  sourcedata::Sₛ
  targetdata::Sₜ
  targetdomain::Dₜ
  task::T
  mapper::M

  # state fields
  mappings::Dict{Symbol,Dict{Int,Int}}

  function LearningProblem{Sₛ,Sₜ,Dₜ,T,M}(sourcedata,
                                         targetdata, targetdomain,
                                         task, mapper) where {Sₛ<:AbstractData,
                                                              Sₜ<:AbstractData,
                                                              Dₜ<:AbstractDomain,
                                                              T<:AbstractLearningTask,
                                                              M<:AbstractMapper}
    sourcevars = keys(variables(sourcedata))
    targetvars = keys(variables(targetdata))

    # assert spatial configuration
    @assert ndims(targetdata) == ndims(targetdomain) "target data and domain must have the same number of dimensions"
    @assert coordtype(targetdata) == coordtype(targetdomain) "target data and domain must have the same coordinate type"

    # assert that tasks are valid for the data
    @assert features(task) ⊆ sourcevars ⊆ targetvars "features must be present in data"
    if task isa SupervisedLearningTask
      @assert label(task) ∈ sourcevars "label must be present in source data"
      varnames = vcat(features(task)..., label(task))
    else
      varnames = features(task)
    end

    mappings = map(targetdata, targetdomain, varnames, mapper)

    new(sourcedata, targetdata, targetdomain, task, mapper, mappings)
  end
end

function LearningProblem(sourcedata::Sₛ, target::Pair{Sₜ,Dₜ}, task::T;
                         mapper::M=SimpleMapper()) where {Sₛ<:AbstractData,
                                                          Sₜ<:AbstractData,
                                                          Dₜ<:AbstractDomain,
                                                          T<:AbstractLearningTask,
                                                          M<:AbstractMapper}
  LearningProblem{Sₛ,Sₜ,Dₜ,T,M}(sourcedata, target[1], target[2], task, mapper)
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
    targetdomain(problem)

Return the target domain of the learning `problem`.
"""
targetdomain(problem::LearningProblem) = problem.targetdomain

"""
    task(problem)

Return the learning task of the learning `problem`.
"""
task(problem::LearningProblem) = problem.task

"""
    mapper(problem)

Return the mapper of the learning `problem`.
"""
mapper(problem::LearningProblem) = problem.mapper

"""
    datamap(problem, var)

Return the mapping from target domain locations to target data
locations for the `var` of the `problem`.
"""
datamap(problem::LearningProblem, var::Symbol) = problem.mappings[var]

"""
    datamap(problem)

Return the mappings from target domain locations to target data
locations for all the variables of the `problem`.
"""
datamap(problem::LearningProblem) = problem.mappings

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::LearningProblem)
  dim = ndims(problem.targetdomain)
  print(io, "$(dim)D LearningProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::LearningProblem)
  println(io, problem)
  println(io, "  source")
  println(io, "    └─data:   ", problem.sourcedata)
  println(io, "  target")
  println(io, "    └─data:   ", problem.targetdata)
  println(io, "    └─domain: ", problem.targetdomain)
  print(  io, "  task: ", problem.task)
end

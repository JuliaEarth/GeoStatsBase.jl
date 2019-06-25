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
struct LearningProblem{Sₛ<:AbstractSpatialData,
                       Sₜ<:AbstractSpatialData,
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
                                         task, mapper) where {Sₛ<:AbstractSpatialData,
                                                              Sₜ<:AbstractSpatialData,
                                                              Dₜ<:AbstractDomain,
                                                              T<:AbstractLearningTask,
                                                              M<:AbstractMapper}
    sourcevars = keys(variables(sourcedata))
    targetvars = keys(variables(targetdata))

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
                         mapper::M=SimpleMapper()) where {Sₛ<:AbstractSpatialData,
                                                          Sₜ<:AbstractSpatialData,
                                                          Dₜ<:AbstractDomain,
                                                          T<:AbstractLearningTask,
                                                          M<:AbstractMapper}
  LearningProblem{Sₛ,Sₜ,Dₜ,T,M}(sourcedata, target[1], target[2], task, mapper)
end

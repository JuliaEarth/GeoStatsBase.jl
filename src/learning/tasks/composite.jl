# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CompositeTask(tasks, [adjacency])

A learning task composed of multiple sub-`tasks`.
The tasks are assumed to be independent, unless
an `adjacency` matrix is provided with the list
of dependencies.

## Examples

A composite task composed of three independent sub-tasks
`t₁`, `t₂` and `t₃`:

```julia
julia> CompositeTask([t₁,t₂,t₃])
```

A composite sequential task `t₁ → t₂ → t₃`:

```julia
julia> CompositeTask([t₁,t₂,t₃], [0 1 0; 0 0 1; 0 0 0])
```

### Notes

Only directed acyclic graphs (DAGs) are permitted.
"""
struct CompositeTask <: AbstractLearningTask
  tasks::Vector{AbstractLearningTask}
  adjacency::Matrix{Int}

  function CompositeTask(tasks, adjacency)
    @assert all(length(tasks) .== size(adjacency)) "invalid adjacency for tasks"
    @assert isacyclic(adjacency) "dependencies must be acyclic"
    new(tasks, adjacency)
  end
end

CompositeTask(tasks::AbstractVector) =
  CompositeTask(tasks, zeros(Int, length(tasks), length(tasks)))

iscomposite(task::CompositeTask) = true

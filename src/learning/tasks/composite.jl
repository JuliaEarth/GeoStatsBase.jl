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

"""
    isacyclic(adjacency)

Check whether or not the `adjacency` matrix is acyclic
using Kahn's topological sort.
"""
function isacyclic(adjacency::AbstractMatrix{Int})
  # copy input to avoid side effects
  A = copy(adjacency)

  # find root nodes
  roots = Vector{Int}()
  for j in 1:size(A, 2)
    if all(A[:,j] .== 0)
      push!(roots, j)
    end
  end

  # Kahn's algorithm
  sorted = Vector{Int}()
  while !isempty(roots)
    i = pop!(roots)
    push!(sorted, i)

    # for all edges i → j
    for j in findall(A[i,:] .== 1)
      # remove edge i → j
      A[i,j] = 0

      # if j has no other incoming edge
      if all(A[:,j] .== 0)
        push!(sorted, j)
      end
    end
  end

  any(A .== 1) ? false : true
end

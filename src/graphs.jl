# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    components(adjacency)

Return connected components of `adjacency`.
"""
function components(adjacency::AbstractMatrix{Int})
  n = size(adjacency, 1)
  vertices = Set(1:n)
  components = Vector{Int}[]
  while !isempty(vertices)
    u = pop!(vertices)
    c = component(adjacency, u)
    for v in setdiff(c, [u])
      pop!(vertices, v)
    end
    push!(components, c)
  end
  components
end

"""
    component(adjacency, vertex)

Return connected component of `adjacency` containing `vertex.
"""
function component(adjacency::AbstractMatrix{Int}, vertex::Int)
  frontier = [vertex]
  visited  = Int[]
  # breadth-first search
  while !isempty(frontier)
    u = pop!(frontier)
    push!(visited, u)
    for v in findall(!iszero, adjacency[u,:])
      if v ∉ visited
        push!(frontier, v)
      end
    end
  end
  visited
end

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

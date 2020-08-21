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
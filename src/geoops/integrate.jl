# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    integrate(data, var; rank=nothing)

Integrate `data` for variable `var` over geometries of given `rank`.
Default rank is the parametric dimension of the underlying domain
where the data is georeferenced.
"""
function integrate(data::Data, vars...; rank=nothing)
  # domain and vertex table
  𝒟 = domain(data)
  𝒯 = values(data, 0)

  valid = Tables.schema(𝒯).names
  @assert vars ⊆ valid "invalid variables for vertex table"

  # retrieve columns
  cols = Tables.columns(𝒯)

  # rank of integration
  R = isnothing(rank) ? paramdim(𝒟) : rank

  # retrieve topology
  topo = topology(𝒟)

  # perform integration over each face
  table = map(faces(topo, R)) do face
    # vertex indices
    inds = collect(indices(face))

    # TODO: better integration rule
    ints = map(vars) do var
      vals = Tables.getcolumn(cols, var)
      mean(vals[inds])
    end

    # row of table with results
    (; zip(vars, ints)...)
  end

  meshdata(𝒟, Dict(R => table))
end
# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    integrate(data, vars...; rank=nothing)

Integrate variables `vars` in vertex table of geospatial `data` over
geometries of given `rank`. Default rank is the parametric dimension
of the underlying geospatial domain.
"""
function integrate(t::AbstractGeoTable, vars...; rank=nothing)
  # domain and vertex table
  dom = domain(t)
  tab = values(t, 0)

  # retrieve columns
  cols = Tables.columns(tab)

  # sanity check
  svars = Symbol.(vars)
  valid = Tables.columnnames(cols)
  @assert svars ⊆ valid "invalid variables for vertex table"

  # vertices and topology
  vert = vertices(dom)
  topo = topology(dom)

  # retrieve vertex values
  vals = ntuple(length(svars)) do i
    Tables.getcolumn(cols, svars[i])
  end

  # rank of integration
  R = isnothing(rank) ? paramdim(dom) : rank

  # integration rule
  rule = GaussLegendre(1)

  # loop over faces
  table = map(faces(topo, R)) do face
    # materialize geometry
    geom = materialize(face, vert)

    # compute measure
    gmeasure = measure(geom)

    # retrieve face indices
    inds = indices(face)

    # retrieve corresponding vertices
    ps = map(i -> vert[i], inds)

    # perform integration for all variables
    ints = map(vals) do val
      # retrieve variable values
      fs = map(i -> val[i], inds)

      # interpolant function
      func = interpolant(geom, fs, ps)

      # average = ∫fdΩ / ∫dΩ
      integral(func, geom, rule) / gmeasure
    end

    # row of table with results
    (; zip(svars, ints)...)
  end

  GeoTable(dom, Dict(R => table))
end

function interpolant(geom, fs, ps)
  p -> let
    n = length(fs)
    sum(eachindex(fs)) do i
      fs[i] * prod([1:(i - 1); (i + 1):n]) do j
        norm(p - ps[j]) / norm(ps[i] - ps[j])
      end
    end
  end
end

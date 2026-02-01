# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    integrate(data; rank=nothing)

Average variables in vertex table of geospatial `data` over
geometries of given `rank`. Default rank is the parametric
dimension of the underlying geospatial domain.
"""
function integrate(t::AbstractGeoTable; rank=nothing)
  # domain and vertex table
  dom = domain(t)
  tab = values(t, 0)

  # retrieve columns
  cols = Tables.columns(tab)
  vars = Tables.columnnames(cols)

  # vertices and topology
  vert = vertices(dom)
  topo = topology(dom)

  # rank of integration
  R = isnothing(rank) ? paramdim(dom) : rank

  # integration rule
  rule = GaussLegendre(1)

  # loop over faces
  table = map(faces(topo, R)) do face
    # retrieve face indices
    inds = indices(face)

    # materialize geometry
    geom = materialize(face, vert)

    # compute measure
    gmeasure = measure(geom)

    # average all variables
    averages = map(vars) do var
      # retrieve function values at vertices
      vals = Tables.getcolumn(cols, var)
      fval = map(i -> vals[i], inds)

      # integrand function
      func = integrand(geom, fval)

      # average = ∫fdΩ / ∫dΩ
      integral(func, geom, rule) / gmeasure
    end

    # row of table with results
    (; zip(vars, averages)...)
  end

  GeoTable(dom, Dict(R => table))
end

function integrand(geom, fval)
  p -> let
    n = length(fval)
    v = vertices(geom)
    sum(eachindex(fval)) do i
      fval[i] * prod([1:(i - 1); (i + 1):n]) do j
        norm(p - v[j]) / norm(v[i] - v[j])
      end
    end
  end
end

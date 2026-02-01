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

  # retrieve vertex variables
  cols = Tables.columns(tab)
  vars = Tables.columnnames(cols)

  # vertices and topology
  vert = vertices(dom)
  topo = topology(dom)

  # rank of integration
  rdim = isnothing(rank) ? paramdim(dom) : rank

  # integration rule
  rule = GaussLegendre(2)

  # loop over faces
  table = map(faces(topo, rdim)) do face
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

  GeoTable(dom, Dict(rdim => table))
end

# barycentric interpolant for triangle
function integrand(tri::Triangle, fval)
  p -> let
    # retrieve vertices
    v = vertices(tri)

    # barycentric system
    A = [(v[2] - v[1]) (v[3] - v[1])]
    b = (p - v[1])

    # normalize by maximum absolute coordinate
    m = maximum(abs, A)
    Am = A / m
    bm = b / m

    # solve system
    w₂, w₃ = Am \ bm

    fval[1] + w₂ * (fval[2] - fval[1]) + w₃ * (fval[3] - fval[1])
  end
end

# bilinear interpolant for quadrangle
function integrand(quad::Quadrangle, fval)
  p -> let
    # retrieve vertices
    v = vertices(quad)

    # interpolate along bottom segment
    v₁₂ = v[2] - v[1]
    v₁ₚ = p - v[1]
    α₁ₚ = (v₁ₚ ⋅ v₁₂) / (v₁₂ ⋅ v₁₂)
    f₁ₚ = (1 - α₁ₚ) * fval[1] + α₁ₚ * fval[2]
    p₁ₚ = v[1] + α₁ₚ * v₁₂

    # interpolate along top segment
    v₄₃ = v[3] - v[4]
    v₄ₚ = p - v[4]
    α₄ₚ = (v₄ₚ ⋅ v₄₃) / (v₄₃ ⋅ v₄₃)
    f₄ₚ = (1 - α₄ₚ) * fval[4] + α₄ₚ * fval[3]
    p₄ₚ = v[4] + α₄ₚ * v₄₃

    # interpolate along bisecting segment
    v₁₄ = p₄ₚ - p₁ₚ
    v₁ₚ = p - p₁ₚ
    α₁ₚ = (v₁ₚ ⋅ v₁₄) / (v₁₄ ⋅ v₁₄)
    (1 - α₁ₚ) * f₁ₚ + α₁ₚ * f₄ₚ
  end
end

# fallback to Lagrange interpolant
function integrand(geom::Geometry, fval)
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

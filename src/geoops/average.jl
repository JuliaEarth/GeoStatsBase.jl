# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    average(data; rank=nothing)

Average variables in vertex table of geospatial `data` over
geometries of given `rank`. Default rank is the parametric
dimension of the underlying geospatial domain.
"""
function average(t::AbstractGeoTable; rank=nothing)
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

    # linear system for barycentric coordinates
    A = [(v[2] - v[1]) (v[3] - v[1])]
    b = (p - v[1])

    # normalize by maximum absolute coordinate
    m = maximum(abs, A)
    Am = A / m
    bm = b / m

    # solve for barycentric coordinates
    w₂, w₃ = Am \ bm

    # linear interpolation inside triangle
    fval[1] + w₂ * (fval[2] - fval[1]) + w₃ * (fval[3] - fval[1])
  end
end

# barycentric interpolant for tetrahedron
function integrand(tetra::Tetrahedron, fval)
  p -> let
    # retrieve vertices
    v = vertices(tetra)

    # linear system for barycentric coordinates
    A = [(v[2] - v[1]) (v[3] - v[1]) (v[4] - v[1])]
    b = (p - v[1])

    # normalize by maximum absolute coordinate
    m = maximum(abs, A)
    Am = A / m
    bm = b / m

    # solve for barycentric coordinates
    w₂, w₃, w₄ = Am \ bm

    # linear interpolation inside tetrahedron
    fval[1] + w₂ * (fval[2] - fval[1]) + w₃ * (fval[3] - fval[1]) + w₄ * (fval[4] - fval[1])
  end
end

# bilinear interpolant for quadrangle
function integrand(quad::Quadrangle, fval)
  p -> let
    # retrieve vertices
    v = vertices(quad)

    # interpolate along bottom segment
    p₁, f₁ = interpsegment(p, v[1], v[2], fval[1], fval[2])

    # interpolate along top segment
    p₂, f₂ = interpsegment(p, v[3], v[4], fval[3], fval[4])

    # interpolate along bisecting segment
    _, f = interpsegment(p, p₁, p₂, f₁, f₂)

    f
  end
end

# interpolate along segment
function interpsegment(p, v₁, v₂, f₁, f₂)
  v₁₂ = v₂ - v₁
  v₁ₚ = p - v₁
  α = (v₁ₚ ⋅ v₁₂) / (v₁₂ ⋅ v₁₂)
  f = (1 - α) * f₁ + α * f₂
  c = v₁ + α * v₁₂
  c, f
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

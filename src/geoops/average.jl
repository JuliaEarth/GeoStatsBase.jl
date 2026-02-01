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

      # integrand function
      func = integrand(geom, map(i -> vals[i], inds))

      # average = ∫fdΩ / ∫dΩ
      integral(func, geom, rule) / gmeasure
    end

    # row of table with results
    (; zip(vars, averages)...)
  end

  GeoTable(dom, Dict(rdim => table))
end

# barycentric interpolant for triangle
function integrand(tri::Triangle, f)
  p -> let
    # retrieve vertices
    v = vertices(tri)

    # linear system for barycentric coordinates
    A = [(v[2] - v[1]) (v[3] - v[1])]
    b = (p - v[1])

    # normalize by maximum absolute coordinate
    m = maximum(abs, A)
    Aₘ = A / m
    bₘ = b / m

    # solve for barycentric coordinates
    w₂, w₃ = Aₘ \ bₘ

    # linear interpolation inside triangle
    f[1] + w₂ * (f[2] - f[1]) + w₃ * (f[3] - f[1])
  end
end

# barycentric interpolant for tetrahedron
function integrand(tetra::Tetrahedron, f)
  p -> let
    # retrieve vertices
    v = vertices(tetra)

    # linear system for barycentric coordinates
    A = [(v[2] - v[1]) (v[3] - v[1]) (v[4] - v[1])]
    b = (p - v[1])

    # normalize by maximum absolute coordinate
    m = maximum(abs, A)
    Aₘ = A / m
    bₘ = b / m

    # solve for barycentric coordinates
    w₂, w₃, w₄ = Aₘ \ bₘ

    # linear interpolation inside tetrahedron
    f[1] + w₂ * (f[2] - f[1]) + w₃ * (f[3] - f[1]) + w₄ * (f[4] - f[1])
  end
end

# bilinear interpolant for quadrangle
function integrand(quad::Quadrangle, f)
  p -> let
    # retrieve vertices
    v = vertices(quad)

    # interpolate along bottom segment
    p₁, f₁ = interpsegment(p, v[1], v[2], f[1], f[2])

    # interpolate along top segment
    p₂, f₂ = interpsegment(p, v[3], v[4], f[3], f[4])

    # interpolate along bisecting segment
    _, fₚ = interpsegment(p, p₁, p₂, f₁, f₂)

    fₚ
  end
end

# trilinear interpolant for hexahedron
function integrand(hex::Hexahedron, f)
  p -> let
    # retrieve vertices
    v = vertices(hex)

    # interpolate along bottom quadrangle
    p₁, f₁ = interpsegment(p, v[1], v[2], f[1], f[2])
    p₂, f₂ = interpsegment(p, v[3], v[4], f[3], f[4])
    p₃, f₃ = interpsegment(p, p₁, p₂, f₁, f₂)

    # interpolate along top quadrangle
    p₄, f₄ = interpsegment(p, v[5], v[6], f[5], f[6])
    p₅, f₅ = interpsegment(p, v[7], v[8], f[7], f[8])
    p₆, f₆ = interpsegment(p, p₄, p₅, f₄, f₅)

    # interpolate across bottom and top quadrangles
    _, fₚ = interpsegment(p, p₃, p₆, f₃, f₆)

    fₚ
  end
end

# interpolate along segment
function interpsegment(p, v₁, v₂, f₁, f₂)
  v₁₂ = v₂ - v₁
  v₁ₚ = p - v₁
  α = (v₁ₚ ⋅ v₁₂) / (v₁₂ ⋅ v₁₂)
  f = (1 - α) * f₁ + α * f₂
  o = v₁ + α * v₁₂
  o, f
end

# fallback to Lagrange interpolant
function integrand(geom::Geometry, f)
  p -> let
    n = length(f)
    v = vertices(geom)
    sum(eachindex(f)) do i
      f[i] * prod([1:(i - 1); (i + 1):n]) do j
        norm(p - v[j]) / norm(v[i] - v[j])
      end
    end
  end
end

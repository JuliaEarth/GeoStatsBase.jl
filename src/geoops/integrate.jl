# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    integrate(data, var; rank=nothing)

Integrate geospatial `data` for variable `var` over geometries of
given `rank`. Default rank is the parametric dimension of the
underlying geospatial domain.
"""
function integrate(t::AbstractGeoTable, vars...; rank=nothing)
  # domain and vertex table
  𝒟 = domain(t)
  𝒯 = values(t, 0)

  valid = Tables.schema(𝒯).names
  @assert vars ⊆ valid "invalid variables for vertex table"

  # vertices and topology
  vert = vertices(𝒟)
  topo = topology(𝒟)

  # retrieve columns
  cols = Tables.columns(𝒯)
  vals = [Tables.getcolumn(cols, var) for var in vars]

  # rank of integration
  R = isnothing(rank) ? paramdim(𝒟) : rank

  # loop over faces
  table = map(faces(topo, R)) do face
    # perform integration of all variables
    ints = _integrate(face, vert, vals)

    # row of table with results
    (; zip(vars, ints)...)
  end

  GeoTable(𝒟, Dict(R => table))
end

# The surface integral ∫fdA over a 2D geometry can be
# expressed as ∫ᵤ∫ᵥf(u,v)||rᵤ×rᵥ||dudv where the vector
# r = [x(u,v), y(u,v), z(u,v)] lives on the geometry and
# where rᵤ = ∂r/∂u and rᵥ = ∂r/∂v are partial derivatives
# with respect to parameters u and v.
#
# For triangles, we can approximate functions linearly
# as f(u,v) = θ₀ + θ₁u + θ₂v using the values at the
# three vertices. This is a 3x3 linear system with
# analytical solution hard-coded below:
#
# |1 0 0| |θ₀|   |f₁|
# |1 1 0| |θ₁| = |f₂|
# |1 0 1| |θ₂|   |f₃|
#
# θ₀ = f₁, θ₁ = f₂-f₁, θ₂ = f₃-f₁
#
# f(u,v) = f₁ + (f₂-f₁)u + (f₃-f₁)v
#
# Coordinate functions can be approximated with the same
# system of equations (isometric approximation):
#
# x(u,v) = x₁ + (x₂-x₁)u + (x₃-x₁)v
# y(u,v) = y₁ + (y₂-y₁)u + (y₃-y₁)v
# z(u,v) = z₁ + (z₂-z₁)u + (z₃-z₁)v
#
# Consequently, we have the following constant:
#
# rᵤ = [(x₂-x₁), (y₂-y₁), (z₂-z₁)]
# rᵥ = [(x₃-x₁), (y₃-y₁), (z₃-z₁)]
#
# ||rᵤ×rᵥ|| = ||(p₂-p₁)×(p₃-p₁)|| = c
#
# where p₁, p₂ and p₃ are the three vertices.
#
# Finally, for the limits of integration u ∈ [0,1]
# and v ∈ [0,1-u] we can solve the integrand as:
#
# ∫ᵤ(∫ᵥf(u,v)dv)dv = ∫ᵤ(f₁(1-u) + (f₂-f₁)u(1-u) + (f₃-f₁)(1-u)²/2)du
#                  = ∫ᵤ((f₁+f₃)/2 + (f₂-f₃-f₁)u + (f₁+f₃-2f₂)u²/2)du
#                  = (f₁+f₃)/2 + (f₂-f₃-f₁)/2 + (f₁+f₃-2f₂)/6
#                  = (f₁+f₂+f₃)/6
#
# which leads to:
#
# ∫ᵤ∫ᵥf(u,v)||rᵤ×rᵥ||dudv = c(f₁+f₂+f₃)/6
function _integrate(face::Connectivity{<:Triangle}, vert, vals)
  i, j, k = indices(face)
  pᵢ, pⱼ, pₖ = vert[[i, j, k]]
  c = norm((pⱼ - pᵢ) × (pₖ - pᵢ))
  [c * (f[i] + f[j] + f[k]) / 6 for f in vals]
end

# fallback method ignores geometry and simply averages
# values of the variables at the vertices
function _integrate(face, vert, vals)
  inds = collect(indices(face))
  [mean(val[inds]) for val in vals]
end

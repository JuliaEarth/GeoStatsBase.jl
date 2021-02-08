# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EllipsoidNeighborhood(semiaxes, angles; convention=:TaitBryanExtr)

An ellipsoid neighborhood with `semiaxes` and `angles`. For 2D ellipses,
there are two semiaxes and one rotation angle. For 3D ellipsoids, there are
three semiaxes and three rotation angles. Different rotation conventions can be
passed via the `convention` keyword argument. The list of conventions is
available in the [aniso2distance](@ref) documentation.
"""
struct EllipsoidNeighborhood <: AbstractBallNeighborhood
  semiaxes::AbstractVector
  angles::AbstractVector
  convention::Symbol
  metric::Mahalanobis

  function EllipsoidNeighborhood(semiaxes, angles; convention=:TaitBryanExtr)
    metric = aniso2distance(semiaxes, angles, convention=convention)
    new(semiaxes, angles, convention, metric)
  end
end

radius(ellips::EllipsoidNeighborhood) = one(eltype(ellips.semiaxes))

metric(ellips::EllipsoidNeighborhood) = ellips.metric

isneighbor(ellips::EllipsoidNeighborhood, xₒ::AbstractVector, x::AbstractVector) =
  evaluate(ellips.metric, xₒ, x) ≤ radius(ellips)

# ------------
# IO methods
# ------------
function Base.show(io::IO, ellips::EllipsoidNeighborhood)
  print(io, "EllipsoidNeighborhood")
end

function Base.show(io::IO, ::MIME"text/plain", ellips::EllipsoidNeighborhood)
  println(io, "EllipsoidNeighborhood")
  println(io, "  semiaxes: ", ellips.semiaxes)
  println(io, "  angles: ", ellips.angles)
  print(  io, "  rotation convention: ", ellips.convention)
end

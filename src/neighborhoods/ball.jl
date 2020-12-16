# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallNeighborhood(radius, metric=Euclidean())

A ball neighborhood with `radius` and `metric`.
"""
struct BallNeighborhood{T,M} <: AbstractNeighborhood
  radius::T
  metric::M

  function BallNeighborhood{T,M}(radius, metric) where {T,M}
    @assert radius > 0 "radius must be positive"
    new(radius, metric)
  end
end

BallNeighborhood(radius::T, metric::M=Euclidean()) where {T,M} =
  BallNeighborhood{T,M}(radius, metric)

"""
    radius(ball)

Return the radius of the `ball`.
"""
radius(ball::BallNeighborhood) = ball.radius

"""
    metric(ball)

Return the metric of the `ball`.
"""
metric(ball::BallNeighborhood) = ball.metric

isneighbor(ball::BallNeighborhood, xₒ::AbstractVector, x::AbstractVector) =
  evaluate(ball.metric, xₒ, x) ≤ ball.radius

"""
    EllipsoidNeighborhood(semiaxes, angles; convention=:TaitBryanExtr)

An ellipsoid neighborhood with `semiaxes` and `angles`. For 2D ellipses,
there are two semiaxes and one rotation angle. For 3D ellipsoids, there are
three semiaxes and three rotation angles. Different rotation conventions can be
passed via the `convention` keyword argument. The list of conventions is
available in the [ aniso2distance ](@ref) documentation.
"""
function EllipsoidNeighborhood(semiaxes, angles; convention=:TaitBryanExtr)
  metric = aniso2distance(semiaxes, angles, convention=convention)
  BallNeighborhood(1.0, metric)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, ball::BallNeighborhood)
  r = ball.radius
  d = ball.metric
  print(io, "BallNeighborhood($r, $d)")
end

function Base.show(io::IO, ::MIME"text/plain", ball::BallNeighborhood)
  println(io, "BallNeighborhood")
  println(io, "  radius: ", ball.radius)
  print(  io, "  metric: ", ball.metric)
end

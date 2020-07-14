# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
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

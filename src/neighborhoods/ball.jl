# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallNeighborhood{N}(radius, metric=Euclidean())

A `N`-dimensional ball neighborhood with `radius` and `metric`.
"""
struct BallNeighborhood{T,N,M} <: AbstractNeighborhood{T,N}
  radius::T
  metric::M
end

function BallNeighborhood{N}(radius::T, metric::M=Euclidean()) where {M,N,T}
  @assert radius > 0 "radius must be positive"
  @assert N > 0 "number of dimensions must be positive"
  BallNeighborhood{T,N,M}(radius, metric)
end

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
function Base.show(io::IO, ball::BallNeighborhood{T,N,M}) where {M,N,T}
  r = ball.radius
  d = ball.metric
  print(io, "$(N)D BallNeighborhood($r, $d)")
end

function Base.show(io::IO, ::MIME"text/plain",
                   ball::BallNeighborhood{T,N,M}) where {M,N,T}
  println(io, "$(N)D BallNeighborhood")
  println(io, "  radius: ", ball.radius)
  print(  io, "  metric: ", ball.metric)
end

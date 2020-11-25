# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallSampling(radius; [options])

A method for sampling isolated points from spatial objects using
a ball neighborhood of given `radius`.

## Options

* `metric`  - Metric for the ball (default to `Euclidean()`)
* `maxsize` - Maximum size of the resulting sample (default to none)
"""
struct BallSampling{T,M} <: SamplingMethod
  radius::T
  metric::M
  maxsize::Union{Int,Nothing}
end

BallSampling(radius; metric=Euclidean(), maxsize=nothing) =
  BallSampling(radius, metric, maxsize)

function sample(object, method::BallSampling)
  N = ncoords(object)
  T = coordtype(object)
  radius = method.radius
  metric = method.metric
  msize  = method.maxsize ≠ nothing ? method.maxsize : Inf

  # neighborhood search method with ball
  ball = BallNeighborhood(radius, metric)
  searcher = NeighborhoodSearch(object, ball)

  # pre-allocate memory for coordinates
  coords = MVector{N,T}(undef)

  locations = Vector{Int}()
  notviewed = trues(nelms(object))
  while length(locations) < msize && any(notviewed)
    location = rand(findall(notviewed))
    coordinates!(coords, object, location)

    # neighbors (including the location)
    neighbors = search(coords, searcher)

    push!(locations, location)
    notviewed[neighbors] .= false
  end

  view(object, locations)
end

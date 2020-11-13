# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallSampler(radius; [options])

A method for sampling isolated points from spatial objects using
a ball neighborhood of given `radius`.

## Options

* `metric`  - Metric for the ball (default to `Euclidean()`)
* `maxsize` - Maximum size of the resulting sample (default to none)
"""
struct BallSampler{T,M} <: AbstractSampler
  radius::T
  metric::M
  maxsize::Union{Int,Nothing}
end

BallSampler(radius; metric=Euclidean(), maxsize=nothing) =
  BallSampler(radius, metric, maxsize)

function sample(object, sampler::BallSampler)
  N = ncoords(object)
  T = coordtype(object)
  radius = sampler.radius
  metric = sampler.metric
  msize  = sampler.maxsize ≠ nothing ? sampler.maxsize : Inf

  # neighborhood search method with ball
  ball = BallNeighborhood(radius, metric)
  searcher = NeighborhoodSearcher(object, ball)

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

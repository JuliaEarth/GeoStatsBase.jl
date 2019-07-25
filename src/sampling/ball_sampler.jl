# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    BallSampler(radius, [maxsize])

A method for sampling isolated points from spatial objects using
a ball neighborhood of given `radius`. The maximum size `maxsize`
of the sample can be specified, but is not required.
"""
struct BallSampler{B<:BallNeighborhood} <: AbstractSampler
  ball::B
  maxsize::Union{Int,Nothing}
end

function BallSampler(radius::Real, maxsize=nothing)
  ball = BallNeighborhood(radius)
  BallSampler{typeof(ball)}(ball, maxsize)
end

function sample(object::AbstractSpatialObject{T,N}, sampler::BallSampler) where {T,N}
  npts = npoints(object)
  ball = sampler.ball
  size = sampler.maxsize ≠ nothing ? sampler.maxsize : Inf

  # neighborhood search method with ball
  searcher = NeighborhoodSearcher(object, ball)

  # pre-allocate memory for coordinates
  coords = MVector{N,T}(undef)

  locations = Vector{Int}()
  notviewed = trues(npts)
  while length(locations) < size && any(notviewed)
    location = rand(findall(notviewed))
    coordinates!(coords, object, location)

    # neighbors (including the location)
    neighbors = search(coords, searcher)

    push!(locations, location)
    notviewed[neighbors] .= false
  end

  view(object, locations)
end

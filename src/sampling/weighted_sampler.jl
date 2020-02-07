# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedSampler(size, [weights]; replace=false)

A method for weighted sampling from spatial objects that produces
samples of given `size` based on `weights` with or without replacement
depending on the option `replace`. By default weights are uniform.
"""
struct WeightedSampler{W<:Union{Vector{<:Real},Nothing}} <: AbstractSampler
  size::Int
  weights::W
  replace::Bool
end

WeightedSampler(size::Int, weights::W=nothing;
                replace=false) where {W<:Union{Vector{<:Real},Nothing}} =
  WeightedSampler(size, weights, replace)

WeightedSampler(size::Int, weights::AbstractWeights; replace=false) =
  WeightedSampler(size, collect(weights), replace)

function sample(object::AbstractSpatialObject, sampler::WeightedSampler)
  n = npoints(object)
  s = sampler.size
  r = sampler.replace
  if s > n && r == false
    @error "invalid sample size for sampling without replacement"
  end
  w = isnothing(sampler.weights) ? fill(1/n, n) : sampler.weights
  @assert length(w) == n "invalid number of weights for object"

  view(object, sample(1:n, Weights(w), s, replace=r))
end

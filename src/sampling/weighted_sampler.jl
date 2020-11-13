# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedSampler(size, [weights]; replace=false)

A method for weighted sampling from spatial objects that produces
samples of given `size` based on `weights` with or without replacement
depending on the option `replace`. By default weights are uniform.
"""
struct WeightedSampler{W} <: AbstractSampler
  size::Int
  weights::W
  replace::Bool
end

WeightedSampler(size, weights=nothing; replace=false) =
  WeightedSampler(size, weights, replace)

function sample(object, sampler::WeightedSampler)
  n = nelms(object)
  s = sampler.size
  w = sampler.weights
  r = sampler.replace
  if s > n && r == false
    @error "invalid sample size for sampling without replacement"
  end
  ws = isnothing(w) ? fill(1/n, n) : collect(w)
  @assert length(ws) == n "invalid number of weights for object"

  view(object, sample(1:n, Weights(ws), s, replace=r))
end

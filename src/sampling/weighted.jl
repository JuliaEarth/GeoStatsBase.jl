# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    WeightedSampling(size, [weights]; replace=false)

A method for weighted sampling from spatial objects that produces
samples of given `size` based on `weights` with or without replacement
depending on the option `replace`. By default weights are uniform.
"""
struct WeightedSampling{W} <: SamplingMethod
  size::Int
  weights::W
  replace::Bool
end

WeightedSampling(size, weights=nothing; replace=false) =
  WeightedSampling(size, weights, replace)

function sample(object, method::WeightedSampling)
  n = nelms(object)
  s = method.size
  w = method.weights
  r = method.replace
  if s > n && r == false
    @error "invalid sample size for sampling without replacement"
  end
  ws = isnothing(w) ? fill(1/n, n) : collect(w)
  @assert length(ws) == n "invalid number of weights for object"

  view(object, sample(1:n, Weights(ws), s, replace=r))
end

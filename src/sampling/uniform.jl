# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniformSampling(size, replace=false)

A method for uniform sampling from spatial objects that produces
samples of given `size` with or without replacement depending on
the option `replace`.
"""
struct UniformSampling <: SamplingMethod
  size::Int
  replace::Bool
end

UniformSampling(size::Int) = UniformSampling(size, false)

function sample(object, method::UniformSampling)
  n = nelms(object)
  s = method.size
  r = method.replace
  if s > n && r == false
    @error "invalid sample size for sampling without replacement"
  end
  view(object, sample(1:n, s, replace=r))
end

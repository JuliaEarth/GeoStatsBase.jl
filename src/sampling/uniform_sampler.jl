# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    UniformSampler

A method for uniform sampling from spatial objects.
"""
struct UniformSampler <: AbstractSampler
  size::Int
  replace::Bool
end

UniformSampler(size::Int) = UniformSampler(size, false)

function sample(object::AbstractSpatialObject, sampler::UniformSampler)
  n = npoints(object)
  s = sampler.size
  r = sampler.replace
  if s > n && r == false
    @error "invalid sample size for sampling without replacement"
  end
  view(object, sample(1:n, s, replace=r))
end

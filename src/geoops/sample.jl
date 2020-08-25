# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    sample(object, nsamples, [weights], replace=false)

Generate `nsamples` samples from spatial `object`
uniformly or using `weights`, with or without
replacement depending on `replace` option.
"""
function sample(object::Union{AbstractDomain,AbstractData}, nsamples::Int,
                weights::AbstractVector=[]; replace=false)
  if isempty(weights)
    sample(object, UniformSampler(nsamples, replace))
  else
    sample(object, WeightedSampler(nsamples, weights, replace))
  end
end
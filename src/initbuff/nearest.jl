# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NearestInit()

A method to initialize buffers using the nearest element in the domain.
"""
struct NearestInit <: InitMethod end

preprocess(sdata, sdomain, ::NearestInit) = domain(sdata), KNearestSearch(sdomain, 1)

function initbuff!(buff, mask, vals, ::NearestInit, preproc)
  domain, searcher = preproc

  @inbounds for ind in 1:nelements(domain)
    inds = search(centroid(domain, ind), searcher)
    if !ismissing(vals[ind])
      buff[inds] .= vals[ind]
      mask[inds] .= true
    end
  end
end

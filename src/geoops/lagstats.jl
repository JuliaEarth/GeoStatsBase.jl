# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    lagstats(geotable; distance=Euclidean(), nmax=4000)

Basic lag `distance` statistics for `geotable` with at most `nmax` samples.
"""
function lagstats(geotable::AbstractGeoTable; distance=Euclidean(), nmax=4000)
  d = domain(geotable)
  n = nelements(d)
  m = min(n, nmax)

  # pick elements at random
  rng = Xoshiro(123)
  inds = rand(rng, 1:n, m)
  unique!(inds)
  while length(inds) < m
    p = m - length(inds)
    more = rand(rng, 1:n, p)
    inds = [inds; more]
    unique!(inds)
  end

  # compute element centroids
  cs = [centroid(d, i) for i in inds]

  # compute pairwise distance
  ij = [(i, j) for j in 1:m for i in (j + 1):m]
  ds = [evaluate(distance, cs[i], cs[j]) for (i, j) in ij]

  (mean=mean(ds), mode=hsm_mode(ds), minimum=minimum(ds), median=median(ds), maximum=maximum(ds))
end

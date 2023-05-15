# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniformFolding(k, shuffle=true)

A method for creating `k` random folds from a spatial object
by sampling elements of the object with a uniform distribution.
Optionally `shuffle` the object before creating the folds.
"""
struct UniformFolding <: FoldingMethod
  k::Int
  shuffle::Bool
end

UniformFolding(k::Int) = UniformFolding(k, true)

function folds(domain::Domain, method::UniformFolding)
  # retrieve parameters
  k, shuffle = method.k, method.shuffle

  # partition domain
  p = partition(domain, UniformPartition(k, shuffle))
  s = indices(p)
  n = length(p)

  function pair(i)
    # source and target subsets
    source = [1:(i - 1); (i + 1):n]
    target = [i]

    # indices within subsets
    sinds = reduce(vcat, s[source])
    tinds = reduce(vcat, s[target])

    sinds, tinds
  end

  (pair(i) for i in 1:n)
end

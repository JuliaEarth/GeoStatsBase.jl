# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RandomFolding(k, shuffle=true)

A method for creating `k` random folds from a spatial object.
Optionally `shuffle` the object before creating the folds.
"""
struct RandomFolding <: FoldingMethod
  k::Int
  shuffle::Bool
end

RandomFolding(k::Int) = RandomFolding(k, true)

function folds(object, method::RandomFolding)
  # retrieve parameters
  k, shuffle = method.k, method.shuffle

  # partition object
  p = partition(object, RandomPartition(k, shuffle))
  s = indices(p)
  n = length(p)

  function pair(i)
    # source and target subsets
    source = [1:i-1; i+1:n]
    target = [i]

    # indices within subsets
    sinds = reduce(vcat, s[source])
    tinds = reduce(vcat, s[target])

    sinds, tinds
  end

  (pair(i) for i in 1:n)
end

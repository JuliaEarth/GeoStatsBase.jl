# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockFolding(sides)

A method for creating folds from a spatial object that
are blocks with given `sides`.
"""
struct BlockFolding{S} <: FoldingMethod
  sides::S
end

function folds(object, method::BlockFolding)
  # retrieve parameters
  sides = method.sides

  # partition object
  p = partition(object, BlockPartition(sides))
  m = metadata(p)[:neighbors]
  s = subsets(p)
  n = length(p)

  function pair(i)
    # source and target subsets
    source = setdiff(1:n, [m[i]; i])
    target = [i]

    # indices within subsets
    sinds = reduce(vcat, s[source])
    tinds = reduce(vcat, s[target])

    sinds, tinds
  end

  (pair(i) for i in 1:n)
end

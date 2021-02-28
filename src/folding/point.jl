# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PointFolding()

A method for creating folds from a spatial object that
are single points.
"""
struct PointFolding <: FoldingMethod end

function folds(object, ::PointFolding)
  n = nelements(object)

  function pair(i)
    # source and target indices
    sinds  = setdiff(1:n, i)
    tinds  = [i]

    sinds, tinds
  end

  (pair(i) for i in 1:n)
end

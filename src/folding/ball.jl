# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallFolding(ball)

A method for creating folds from a spatial object that
are centers of balls.
"""
struct BallFolding{B} <: FoldingMethod
  ball::B
end

function folds(object, method::BallFolding)
  # retrieve parameters
  ball = method.ball

  # create search method
  searcher = NeighborhoodSearch(object, ball)
  n = nelms(object)

  function pair(i)
    # source and target indices
    coords = coordinates(object, i)
    inside = search(coords, searcher)
    sinds  = setdiff(1:n, inside)
    tinds  = [i]

    sinds, tinds
  end

  (pair(i) for i in 1:n)
end

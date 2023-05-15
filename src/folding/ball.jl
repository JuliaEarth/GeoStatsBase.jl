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

function folds(domain::Domain, method::BallFolding)
  # retrieve parameters
  ball = method.ball
  n = nelements(domain)

  # create search method
  searcher = BallSearch(domain, ball)

  function pair(i)
    # source and target indices
    point = centroid(domain, i)
    inside = search(point, searcher)
    sinds = setdiff(1:n, inside)
    tinds = [i]

    sinds, tinds
  end

  (pair(i) for i in 1:n)
end

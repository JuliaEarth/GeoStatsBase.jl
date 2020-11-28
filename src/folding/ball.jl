# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallFolding(object, sides)

A method for creating folds from a spatial `object` that are blocks
with given `sides`.
"""
struct BallFolding{O,B,S} <: FoldingMethod
  # input fields
  object::O
  ball::B

  # state fields
  searcher::S
end

function BallFolding(object, ball)
  searcher = NeighborhoodSearch(object, ball)
  O = typeof(object)
  B = typeof(ball)
  S = typeof(searcher)
  BallFolding{O,B,S}(object, ball, searcher)
end

function Base.getindex(method::BallFolding, ind::Int)
  # source and target indices
  nfolds = nelms(method.object)
  coords = coordinates(method.object, ind)
  inside = search(coords, method.searcher)
  sinds  = setdiff(1:nfolds, inside)
  tinds  = [ind]

  # return views
  train = view(method.object, sinds)
  test  = view(method.object, tinds)
  train, test
end

Base.length(method::BallFolding) = nelms(method.object)

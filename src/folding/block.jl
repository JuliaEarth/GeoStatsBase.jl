# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockFolding(object, sides)

A method for creating folds from a spatial `object` that are blocks
with given `sides`.
"""
struct BlockFolding{O,S} <: FoldingMethod
  # input fields
  object::O
  sides::S

  # state fields
  subsets::Vector{Vector{Int}}
  neighbors::Vector{Vector{Int}}
end

function BlockFolding(object, sides)
  p = partition(object, BlockPartition(sides))
  s, n = subsets(p), metadata(p)[:neighbors]
  BlockFolding{typeof(object),typeof(sides)}(object, sides, s, n)
end

function Base.getindex(method::BlockFolding, ind::Int)
  # source and target subsets
  nfolds = length(method.subsets)
  source = setdiff(1:nfolds, [method.neighbors[ind]; ind])
  target = [ind]

  # indices within subsets
  sinds = reduce(vcat, method.subsets[source])
  tinds = reduce(vcat, method.subsets[target])

  # return views
  train = view(method.object, sinds)
  test  = view(method.object, tinds)
  train, test
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RandomFolding(object, k, shuffle=true)

A method for creating `k` random folds from a spatial `object`.
Optionally `shuffle` the `object` before creating the folds.
"""
struct RandomFolding{O} <: FoldingMethod
  # input fields
  object::O
  k::Int
  shuffle::Bool

  # state fields
  subsets::Vector{Vector{Int}}
end

function RandomFolding(object, k::Int, shuffle::Bool=true)
  p = partition(object, RandomPartition(k, shuffle))
  RandomFolding{typeof(object)}(object, k, shuffle, subsets(p))
end

function Base.getindex(method::RandomFolding, ind::Int)
  # source and target subsets
  nfolds = length(method.subsets)
  source = [1:ind-1; ind+1:nfolds]
  target = [ind]

  # indices within subsets
  sinds = reduce(vcat, method.subsets[source])
  tinds = reduce(vcat, method.subsets[target])

  # return views
  train = view(method.object, sinds)
  test  = view(method.object, tinds)
  train, test
end

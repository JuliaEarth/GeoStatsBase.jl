# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    FractionPartitioner(fraction, shuffle=true)

A method for partitioning spatial objects according to a given `fraction`.
Optionally `shuffle` elements before partitioning.
"""
struct FractionPartitioner <: AbstractPartitioner
  fraction::Float64
  shuffle::Bool

  function FractionPartitioner(fraction, shuffle)
    @assert 0 < fraction < 1 "fraction must be in interval (0,1)"
    new(fraction, shuffle)
  end
end

FractionPartitioner(fraction) = FractionPartitioner(fraction, true)

function partition(object, p::FractionPartitioner)
  n = nelms(object)
  f = round(Int, p.fraction * n)

  locs = p.shuffle ? randperm(n) : 1:n
  subsets = [locs[1:f], locs[f+1:n]]

  SpatialPartition(object, subsets)
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
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

function partition(object::AbstractSpatialObject{T,N},
                   p::FractionPartitioner) where {N,T}
  npts = npoints(object)
  frac = round(Int, p.fraction * npts)

  locs = p.shuffle ? randperm(npts) : 1:npts
  subsets = [locs[1:frac], locs[frac+1:npts]]

  SpatialPartition(object, subsets)
end

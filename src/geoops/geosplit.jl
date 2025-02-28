# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    geosplit(object, fraction, [normal])

Split geospatial `object` into two parts where the first
part has a `fraction` of the elements. Optionally, the
split is performed perpendicular to a `normal` direction.
"""
function geosplit(object, fraction::Real, normal=nothing)
  if isnothing(normal)
    partition(object, FractionPartition(fraction))
  else
    partition(object, BisectFractionPartition(normal; fraction))
  end
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

partitioninds(rng::AbstractRNG, geotable::AbstractGeoTable, method::PartitionMethod) =
  partitioninds(rng, domain(geotable), method)
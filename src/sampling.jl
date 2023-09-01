# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

sampleinds(rng::AbstractRNG, geotable::AbstractGeoTable, method::DiscreteSamplingMethod) =
  sampleinds(rng, domain(geotable), method)
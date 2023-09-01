# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

function apply(transform::GeometricTransform, geotable::AbstractGeoTable)
  newdom, cache = apply(transform, domain(geotable))
  newdata = georef(values(geotable), newdom)
  newdata, cache
end

function revert(transform::GeometricTransform, newdata::AbstractGeoTable, cache)
  dom = revert(transform, domain(newdata), cache)
  georef(values(newdata), dom)
end

function reapply(transform::GeometricTransform, geotable::AbstractGeoTable, cache)
  newdom = reapply(transform, domain(geotable), cache)
  georef(values(geotable), newdom)
end

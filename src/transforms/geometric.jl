# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

function apply(transform::GeometricTransform, data::Data)
  newdom, cache = apply(transform, domain(data))
  newdata = georef(values(data), newdom)
  newdata, cache
end

function revert(transform::GeometricTransform, newdata::Data, cache)
  dom = revert(transform, domain(newdata), cache)
  georef(values(newdata), dom)
end

function reapply(transform::GeometricTransform, data::Data, cache)
  newdom = reapply(transform, domain(data), cache)
  georef(values(data), newdom)
end

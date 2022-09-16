# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# specialize TableTransforms.jl API for geospatial data
BUILTIN_TRANSF = [setdiff(subtypes(Transform), (Colwise, Stateless));
                  subtypes(Colwise); subtypes(Stateless)]
SPECIAL_TRANSF = [Sort, Sample, Filter, DropMissing, Sequential, Parallel]
DEFAULT_TRANSF = setdiff(BUILTIN_TRANSF, SPECIAL_TRANSF)

# --------------------
# DEFAULT DEFINITIONS
# --------------------

for TRANS in DEFAULT_TRANSF
  @eval function apply(transform::$TRANS, data::Data)
    newtable, cache = apply(transform, values(data))
    georef(newtable, domain(data)), cache
  end

  if isrevertible(TRANS)
    @eval function revert(transform::$TRANS, newdata::Data, cache)
      table = revert(transform, values(newdata), cache)
      georef(table, domain(newdata))
    end
  end

  @eval function reapply(transform::$TRANS, data::Data, cache)
    table = reapply(transform, values(data), cache)
    georef(table, domain(data))
  end
end

# --------------
# SPECIAL CASES
# --------------

function apply(transform::Sample, data::Data)
  size    = transform.size
  weights = transform.weights
  replace = transform.replace
  ordered = transform.ordered
  rng     = transform.rng

  method  = WeightedSampling(size, weights,
                             replace=replace,
                             ordered=ordered)

  sample(rng, data, method), nothing
end
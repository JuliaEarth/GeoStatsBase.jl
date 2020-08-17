# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PredicateFilter(pred)

A filter method that retains all locations according to
a predicate function `pred`. A predicate function takes
samples as input, e.g. `pred(s) = s.precipitation > 100`.
"""
struct PredicateFilter <: AbstractFilter
  pred::Function
end

function filter(sdata, filt::PredicateFilter)
  𝒯 = values(sdata)
  𝒟 = domain(sdata)

  # row table view
  ctor = Tables.materializer(𝒯)
  rows = Tables.rows(𝒯)

  # locations to retain
  locs = findall(filt.pred, rows)

  # return point set
  table = ctor(rows[locs])
  coord = coordinates(𝒟, locs)

  georef(table, coord)
end
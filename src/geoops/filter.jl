# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    filter(pred, sdata)

Retain all locations in spatial data `sdata` according to
a predicate function `pred`. A predicate function takes
table rows as input, e.g. `pred(r) = r.state == "CA"`.
"""
function filter(pred, sdata::AbstractData)
  𝒯 = values(sdata)
  𝒟 = domain(sdata)

  # row table view
  ctor = Tables.materializer(𝒯)
  rows = Tables.rows(𝒯)

  # indices to retain
  inds = findall(pred, rows)

  # return point set
  table = ctor(rows[inds])
  coord = coordinates(𝒟, inds)

  georef(table, coord)
end
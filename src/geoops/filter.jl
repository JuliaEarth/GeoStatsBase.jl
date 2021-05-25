# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    filter(pred, data)

Retain all locations in geospatial `data` according to
a predicate function `pred`. A predicate function takes
table rows as input, e.g. `pred(r) = r.state == "CA"`.
"""
function Base.filter(pred, data::D) where {D<:Data}
  𝒯 = values(data)
  𝒟 = domain(data)

  # row table view
  ctor = Tables.materializer(𝒯)
  rows = Tables.rows(𝒯)

  # indices to retain
  inds = findall(pred, rows)

  # return point set
  dom = view(𝒟, inds)
  tab = ctor(rows[inds])
  dat = Dict(paramdim(dom) => tab)

  constructor(D)(dom, dat)
end

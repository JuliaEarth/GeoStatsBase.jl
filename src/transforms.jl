# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

TableTransforms.divide(data::Data) = values(data), domain(data)
TableTransforms.attach(feat, meta) = georef(feat, meta)

# --------------
# SPECIAL CASES
# --------------

function apply(transform::Sample, data::Data)
  table = values(data)

  inds, _ = TableTransforms.indices(transform, table)

  newrow = view(Tables.rowtable(table), inds)
  newdom = view(domain(data), inds)

  newtab = newrow |> Tables.materializer(table)

  georef(newtab, newdom), nothing
end
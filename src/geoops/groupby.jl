# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @groupby(data, col₁, col₂, ..., colₙ)
    @groupby(data, [col₁, col₂, ..., colₙ])
    @groupby(data, (col₁, col₂, ..., colₙ))

Group geospatial `data` by columns `col₁`, `col₂`, ..., `colₙ`.

    @groupby(data, regex)

Group geospatial `data` by columns that match with `regex`.

# Examples

```julia
@groupby(data, 1, 3, 5)
@groupby(data, [:a, :c, :e])
@groupby(data, ("a", "c", "e"))
@groupby(data, r"[ace]")
```
"""
macro groupby(data::Symbol, cols...)
  tuple = Expr(:tuple, esc.(cols)...)
  :(_groupby($(esc(data)), $tuple))
end

macro groupby(data::Symbol, cols)
  :(_groupby($(esc(data)), $(esc(cols))))
end

_groupby(data::AbstractGeoTable, cols) = _groupby(data, selector(cols))
_groupby(data::AbstractGeoTable, cols::C...) where {C<:Column} = _groupby(data, selector(cols))

function _groupby(data::AbstractGeoTable, selector::ColumnSelector)
  table = values(data)

  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = selector(names)

  scolumns = [Tables.getcolumn(cols, nm) for nm in snames]
  srows = collect(zip(scolumns...))

  urows = unique(srows)
  inds = map(row -> findall(isequal(row), srows), urows)

  metadata = Dict(:names => snames, :rows => urows)
  Partition(data, inds, metadata)
end

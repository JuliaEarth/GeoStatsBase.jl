# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @groupby(geotable, col₁, col₂, ..., colₙ)
    @groupby(geotable, [col₁, col₂, ..., colₙ])
    @groupby(geotable, (col₁, col₂, ..., colₙ))

Partition `geotable` based on columns `col₁`, `col₂`, ..., `colₙ`.

    @groupby(geotable, regex)

Partition `geotable` based on columns that match with `regex`.

# Examples

```julia
@groupby(geotable, 1, 3, 5)
@groupby(geotable, [:a, :c, :e])
@groupby(geotable, ("a", "c", "e"))
@groupby(geotable, r"[ace]")
```
"""
macro groupby(geotable::Symbol, cols...)
  spec = Expr(:tuple, esc.(cols)...)
  :(_groupby($(esc(geotable)), $spec))
end

macro groupby(geotable::Symbol, spec)
  :(_groupby($(esc(geotable)), $(esc(spec))))
end

_groupby(geotable::AbstractGeoTable, spec) = _groupby(geotable, colspec(spec))
_groupby(geotable::AbstractGeoTable, cols::T...) where {T<:Col} = _groupby(geotable, colspec(cols))

function _groupby(geotable::AbstractGeoTable, colspec::ColSpec)
  table = values(geotable)

  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(colspec, names)

  scolumns = [Tables.getcolumn(cols, nm) for nm in snames]
  srows = collect(zip(scolumns...))

  urows = unique(srows)
  inds = map(row -> findall(isequal(row), srows), urows)

  metadata = Dict(:names => snames, :rows => urows)
  Partition(geotable, inds, metadata)
end

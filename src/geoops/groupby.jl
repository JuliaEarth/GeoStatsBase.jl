# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @groupby(data, col₁, col₂, ..., colₙ)
    @groupby(data, [col₁, col₂, ..., colₙ])
    @groupby(data, (col₁, col₂, ..., colₙ))

Partition geospatial `data` according to selected columns `col₁`, `col₂`, ..., `colₙ`.

    @groupby(data, regex)

Partition geospatial `data` according to columns that match with `regex`.

# Examples

```julia
@groupby(data, 1, 3, 5)
@groupby(data, [:a, :c, :e])
@groupby(data, ("a", "c", "e"))
@groupby(data, r"[ace]")
```
"""
macro groupby(data::Symbol, cols...)
  spec = Expr(:tuple, esc.(cols)...)
  :(_groupby($(esc(data)), $spec))
end

macro groupby(data::Symbol, spec)
  :(_groupby($(esc(data)), $(esc(spec))))
end

_groupby(data::Data, spec) = _groupby(data, colspec(spec))
_groupby(data::Data, cols::T...) where {T<:Col} = _groupby(data, colspec(cols))

function _groupby(data::Data, colspec::ColSpec)
  table = values(data)

  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(colspec, names)

  scolumns = [Tables.getcolumn(cols, nm) for nm in snames]
  srows = collect(zip(scolumns...))

  urows = unique(srows)
  inds = map(row -> findall(isequal(row), srows), urows)

  metadata = Dict(:names => snames, :rows => urows)
  Partition(data, inds, metadata)
end

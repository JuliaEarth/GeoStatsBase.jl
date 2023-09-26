# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const DEFAULTFUNS = [
  :mean => _skipmissing(mean),
  :minimum => _skipmissing(minimum),
  :median => _skipmissing(median),
  :maximum => _skipmissing(maximum),
  :nmissing => x -> count(ismissing, x)
]

"""
    describe(geotable, col₁, col₂, ..., colₙ; funs=[fun₁, fun₂, ..., funₙ])
    describe(geotable, [col₁, col₂, ..., colₙ]; funs=[:name₁ => fun₁, ..., :nameₙ => funₙ])
    describe(geotable, (col₁, col₂, ..., colₙ); funs=Dict(:name₁ => fun₁, ..., :nameₙ => funₙ))

Return descriptive table of columns/variables `col₁`, `col₂`, ..., `colₙ`,
using the descriptive functions `fun₁`, `fun₂`, ..., `funₙ`.
Default functions are `mean`, `minimum`, `median`, `maximum`, `nmissing`.

    describe(geotable; funs=[fun₁, fun₂, ..., funₙ])
    describe(geotable; funs=[:name₁ => fun₁, ..., :nameₙ => funₙ])
    describe(geotable; funs=Dict(:name₁ => fun₁, ..., :nameₙ => funₙ))

Return descriptive table of all `geotable` columns.

    describe(geotable, regex; funs=[fun₁, fun₂, ..., funₙ])
    describe(geotable, regex; funs=[:name₁ => fun₁, ..., :nameₙ => funₙ])
    describe(geotable, regex; funs=Dict(:name₁ => fun₁, ..., :nameₙ => funₙ))

Return descriptive table of columns that match with `regex`.

# Examples

```julia
describe(geotable)
describe(geotable, funs=[mean, median])
describe(geotable, 1, 3, 5, funs=[std, var])
describe(geotable, [:a, :c, :e], funs=[maximum, minimum])
describe(geotable, ("a", "c", "e"), funs=[:min => minimum, :max => maximum])
describe(geotable, r"[ace]", funs=Dict(:min => minimum, :max => maximum))
```
"""
describe(geotable::AbstractGeoTable, selector::ColumnSelector; funs=DEFAULTFUNS) = _describe(geotable, selector, funs)

describe(geotable::AbstractGeoTable; kwargs...) = describe(geotable, AllSelector(); kwargs...)
describe(geotable::AbstractGeoTable, cols; kwargs...) = describe(geotable, selector(cols); kwargs...)
describe(geotable::AbstractGeoTable, cols::C...; kwargs...) where {C<:Column} =
  describe(geotable, selector(cols); kwargs...)

_describe(geotable::AbstractGeoTable, selector::ColumnSelector, funs::Dict{Symbol}) =
  _describe(geotable, selector, collect(funs))

_describe(geotable::AbstractGeoTable, selector::ColumnSelector, funs::AbstractVector) =
  _describe(geotable, selector, nameof.(funs) .=> funs)

function _describe(geotable::AbstractGeoTable, selector::ColumnSelector, funs::AbstractVector{<:Pair{Symbol}})
  table = values(geotable)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = selector(names)

  pairs = []
  push!(pairs, :variable => snames)
  for (fname, fun) in funs
    column = map(snames) do name
      try
        x = Tables.getcolumn(cols, name)
        fun(x)
      catch
        nothing
      end
    end
    push!(pairs, fname => column)
  end

  TypedTables.Table(; pairs...)
end

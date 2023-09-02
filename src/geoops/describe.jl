const DEFAULTFUNS =
  [:mean => mean, :minimum => minimum, :median => median, :maximum => maximum, :nmissing => x -> count(ismissing, x)]

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
describe(geotable::AbstractGeoTable, colspec::ColSpec; funs=DEFAULTFUNS) = _describe(geotable, colspec, funs)

describe(geotable::AbstractGeoTable; kwargs...) = describe(geotable, AllSpec(); kwargs...)
describe(geotable::AbstractGeoTable, spec; kwargs...) = describe(geotable, colspec(spec); kwargs...)
describe(geotable::AbstractGeoTable, cols::T...; kwargs...) where {T<:Col} =
  describe(geotable, colspec(cols); kwargs...)

_describe(geotable::AbstractGeoTable, colspec::ColSpec, funs::Dict{Symbol}) =
  _describe(geotable, colspec, collect(funs))

_describe(geotable::AbstractGeoTable, colspec::ColSpec, funs::AbstractVector) =
  _describe(geotable, colspec, nameof.(funs) .=> funs)

function _describe(geotable::AbstractGeoTable, colspec::ColSpec, funs::AbstractVector{<:Pair{Symbol}})
  table = values(geotable)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(colspec, names)

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

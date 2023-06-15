"""
    nmissing(iter)

Count the missing values in iterator `iter`.
"""
nmissing(iter) = count(ismissing, iter)

const DEFAULTFUNS = [
  :mean => mean, 
  :minimum => minimum, 
  :median => median, 
  :maximum => maximum, 
  :nmissing => nmissing
]

"""
    describe(data, col₁, col₂, ..., colₙ; funs=[fun₁, fun₂, ..., funₙ])
    describe(data, [col₁, col₂, ..., colₙ]; funs=[:name₁ => fun₁, ..., :nameₙ => funₙ])
    describe(data, (col₁, col₂, ..., colₙ); funs=Dict(:name₁ => fun₁, ..., :nameₙ => funₙ))

Return descriptive table of columns/variables `col₁`, `col₂`, ..., `colₙ`,
using the descriptive functions `fun₁`, `fun₂`, ..., `funₙ`.
Each row in the table represents a variable and each column a descriptive function.
If you want custom column names, you can pass `name₁`, `name₂`, ..., `nameₙ`,
otherwise function names will be used. If descriptive functions are not passed, 
the default functions will be used, they are: `mean`, `minimum`, `median`, `maximum`, `nmissing`.

    describe(data; funs=[fun₁, fun₂, ..., funₙ])
    describe(data; funs=[:name₁ => fun₁, ..., :nameₙ => funₙ])
    describe(data; funs=Dict(:name₁ => fun₁, ..., :nameₙ => funₙ))

Return descriptive table of all `data` columns.

    describe(data, regex; funs=[fun₁, fun₂, ..., funₙ])
    describe(data, regex; funs=[:name₁ => fun₁, ..., :nameₙ => funₙ])
    describe(data, regex; funs=Dict(:name₁ => fun₁, ..., :nameₙ => funₙ))

Return descriptive table of columns that match with `regex`.

# Examples

```julia
table = (x=rand(10), y=rand(10), z=rand(10))
data = georef(table, rand(2, 10))

describe(data)
describe(data, funs=[mean, median])
describe(data, 1, 3, 5, funs=[std, var])
describe(data, [:a, :c, :e], funs=[maximum, minimum])
describe(data, ("a", "c", "e"), funs=[:min => minimum, :max => maximum])
describe(data, r"[ace]", funs=Dict(:min => minimum, :max => maximum))
```
"""
describe(data::Data, colspec::ColSpec; funs=DEFAULTFUNS) = _describe(data, colspec, funs)

describe(data::Data; kwargs...) = describe(data, AllSpec(); kwargs...)
describe(data::Data, spec; kwargs...) = describe(data, colspec(spec); kwargs...)
describe(data::Data, cols::T...; kwargs...) where {T<:Col} = describe(data, colspec(cols); kwargs...)

_describe(data::Data, colspec::ColSpec, funs::Dict{Symbol}) =
  _describe(data, colspec, collect(funs))

_describe(data::Data, colspec::ColSpec, funs::AbstractVector) =
  _describe(data, colspec, nameof.(funs) .=> funs)

function _describe(data::Data, colspec::ColSpec, funs::AbstractVector{<:Pair{Symbol}})
  table = values(data)
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

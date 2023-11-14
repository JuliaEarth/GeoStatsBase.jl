# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    describe(geotable)
    describe(geotable, fun₁, name₂ => fun₂, ..., funₙ; skipmissing=true)

Return descriptive table of all `geotable` columns using the descriptive 
functions `fun₁`, `fun₂`, ..., `funₙ`, and skipping or not the missing values
using the `skipmissing` keyword argument.
Optionally, define a `nameᵢ` to `funᵢ` by passing a pair.
If the descriptive functions are not passed, the default functions will be used,
they are: `mean`, `minimum`, `median`, `maximum`, `nmissing`.

    describe(geotable; cols=[col₁, col₂, ..., colₙ])
    describe(geotable; cols=(col₁, col₂, ..., colₙ))
    describe(geotable, fun₁, name₂ => fun₂, ..., funₙ; cols=[col₁, col₂, ..., colₙ], skipmissing=true)
    describe(geotable, fun₁, name₂ => fun₂, ..., funₙ; cols=(col₁, col₂, ..., colₙ), skipmissing=true)

Return descriptive table of columns `col₁`, `col₂`, ..., `colₙ`.

    describe(geotable; cols=regex)
    describe(geotable; cols=regex)
    describe(geotable, fun₁, name₂ => fun₂, ..., funₙ; cols=regex, skipmissing=true)
    describe(geotable, fun₁, name₂ => fun₂, ..., funₙ; cols=regex, skipmissing=true)

Return descriptive table of columns that match with `regex`.

# Examples

```julia
describe(geotable)
describe(geotable, mean, median)
describe(geotable, std, var, cols=(1, 3, 5))
describe(geotable, maximum, minimum, cols=[:a, :c, :e])
describe(geotable, :min => minimum, first, last, cols=("a", "c", "e"))
describe(geotable, :min => minimum, :max => maximum, cols=r"[ace]", skipmissing=false)
```
"""
describe(geotable::AbstractGeoTable; cols=AllSelector()) = _describe(geotable, DEFAULTFUNS, selector(cols), false)
function describe(geotable::AbstractGeoTable, funs...; cols=AllSelector(), skipmissing=true)
  funpairs = map(_funpair, collect(funs))
  _describe(geotable, funpairs, selector(cols), skipmissing)
end

function _describe(
  geotable::AbstractGeoTable,
  funpairs::AbstractVector{<:Pair{Symbol}},
  selector::ColumnSelector,
  skipmissing::Bool
)
  table = values(geotable)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = selector(names)

  pairs = []
  push!(pairs, :variable => string.(snames))
  for (name, fun) in funpairs
    column = map(snames) do name
      try
        x = Tables.getcolumn(cols, name)
        _applyfun(skipmissing ? _skipmissing(fun) : fun, x)
      catch
        nothing
      end
    end
    push!(pairs, name => column)
  end

  TypedTables.Table(; pairs...)
end

_funname(fun) = Symbol(repr(fun, context=:compact => true))

_funpair(fun) = _funname(fun) => fun
_funpair(pair::Pair{Symbol}) = pair
_funpair(pair::Pair{<:AbstractString}) = Symbol(first(pair)) => last(pair)

_applyfun(fun, x) = _applyfun(elscitype(x), fun, x)
_applyfun(::Type, fun, x) = fun(x)
_applyfun(::Type{Categorical}, fun, x) = fun(categorical(x))

function _skipmissing(fun)
  x -> begin
    vs = skipmissing(x)
    isempty(vs) ? missing : fun(collect(vs))
  end
end

const DEFAULTFUNS = [
  :mean => _skipmissing(mean),
  :minimum => _skipmissing(minimum),
  :median => _skipmissing(median),
  :maximum => _skipmissing(maximum),
  :nmissing => x -> count(ismissing, x)
]

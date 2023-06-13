"""
    nmissing(iter)

Count the missing values in iterator `iter`.
"""
nmissing(iter) = count(ismissing, iter)

const DEFAULTFUNS = [mean, minimum, median, maximum, nmissing]

"""
    describe(data, col₁, col₂, ..., colₙ; funs=[fun₁, fun₂, ..., funₙ])
    describe(data, [col₁, col₂, ..., colₙ]; funs=[fun₁, fun₂, ..., funₙ])
    describe(data, (col₁, col₂, ..., colₙ); funs=[fun₁, fun₂, ..., funₙ])

Return descriptive table of columns/variables `col₁`, `col₂`, ..., `colₙ`,
using the descriptive functions `fun₁`, `fun₂`, ..., `funₙ`.
Each row in the table represents a variable and each column a descriptive function.
If descriptive functions are not passed, the default functions will be used, they are:
`mean`, `minimum`, `median`, `maximum`, `nmissing`.

    describe(data; funs=[fun₁, fun₂, ..., funₙ])

Return descriptive table of all `data` columns.

    describe(data, regex; funs=[fun₁, fun₂, ..., funₙ])

Return descriptive table of columns that match with `regex`.
"""
describe(data::Data, colspec::ColSpec; funs=DEFAULTFUNS) = _describe(data, colspec, collect(Function, funs))

describe(data::Data; kwargs...) = describe(data, AllSpec(); kwargs...)
describe(data::Data, spec; kwargs...) = describe(data, colspec(spec); kwargs...)
describe(data::Data, cols::T...; kwargs...) where {T<:Col} = describe(data, colspec(cols); kwargs...)

function _describe(data::Data, colspec::ColSpec, funs::Vector{Function})
  table = values(data)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(colspec, names)

  pairs = []
  push!(pairs, :variable => snames)
  for fun in funs
    column = map(snames) do name
      try
        x = Tables.getcolumn(cols, name)
        fun(x)
      catch
        nothing
      end
    end
    push!(pairs, nameof(fun) => column)
  end

  TypedTables.Table(; pairs...)
end

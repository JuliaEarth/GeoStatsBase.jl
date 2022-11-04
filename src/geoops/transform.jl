# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @transform(data, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

Return a new data object with `data` columns and new columns
`col₁`, `col₂`, ..., `colₙ` defined by expressions
`expr₁`, `expr₂`, ..., `exprₙ`. In each expression the `data`
columns are represented by symbols and the functions
use `broadcast` by default. If there are columns in the table 
with the same name as the new columns, these will be replaced.

# Examples

```julia
@transform(data, :z = :x + 2*:y)
@transform(data, :w = :x^2 - :y^2)
@transform(data, :sinx = sin(:x), :cosy = cos(:y))
```
"""
macro transform(data::Symbol, exprs...)
  splits   = map(expr -> _split(expr), exprs)
  colnames = first.(splits)
  colexprs = last.(splits)
  quote
    local data = $(esc(data))
    _transform(data, [$(colnames...)], [$(colexprs...)])
  end
end

function _transform(data::D, tnames, tcolumns) where {D<:Data}
  dom   = domain(data)
  table = values(data)

  cols    = Tables.columns(table)
  names   = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  for (nm, col) in zip(tnames, tcolumns)
    if nm ∈ names
      i = findfirst(==(nm), names)
      columns[i] = col
    else
      push!(names, nm)
      push!(columns, col)
    end
  end

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(dom) => newtable)
  constructor(D)(dom, vals)
end

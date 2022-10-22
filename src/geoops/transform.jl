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
  splits = map(expr -> _split(data, expr), exprs)
  colnames = first.(splits)
  colexprs = last.(splits)
  texpr = :(GeoStatsBase._transform($data, [$(colnames...)], [$(colexprs...)]))
  esc(texpr)
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

# macro utils
function _split(data::Symbol, expr::Expr)
  if expr.head ≠ :(=)
    error("Invalid expression")
  end

  colname = expr.args[1]
  colexpr = _colexpr(data, expr.args[2])

  colname, colexpr
end

function _colexpr(data::Symbol, arg::Expr)
  expr = copy(arg)
  _preprocess!(data, expr)
  expr
end

function _colexpr(data::Symbol, arg::QuoteNode)
  if arg.value isa Symbol
    _makeexpr(data, arg)
  else
    error("Invalid expression")
  end
end

_colexpr(::Symbol, arg::Symbol) = arg
_colexpr(::Symbol, ::Any) = error("Invalid expression")

_makeexpr(data::Symbol, nm::QuoteNode) = :($data[$nm])

function _preprocess!(data::Symbol, expr::Expr)
  if expr.head ≠ :call
    error("Invalid expression")
  end

  pushfirst!(expr.args, :broadcast)
  
  len  = length(expr.args)
  args = view(expr.args, 3:len)

  for (i, arg) in zip(3:len, args)
    if arg isa QuoteNode
      if arg.value isa Symbol
        expr.args[i] = _makeexpr(data, arg)
      end
    end

    if arg isa Expr
      _preprocess!(data, arg)
    end
  end
end

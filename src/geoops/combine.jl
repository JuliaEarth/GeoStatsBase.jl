# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @combine(data, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

Returns a new data object with each column 
`:col₁`, `:col₂`, ..., `:colₙ` being a reduction of `data` columns 
defined by expressions `expr₁`, `expr₂`, ..., `exprₙ`.
If `data` is a `Partition` object returned by `@groupby` macro,
the reduction expressions will be applied in each `Partition` group.

See also: [`@groupby`](@ref).

# Examples

```julia
using Statistics

@combine(data, :x_sum = sum(:x))
@combine(data, :x_mean = mean(:x))

p = @groupby(data, :y)
@combine(p, :x_prod = prod(:x))
@combine(p, :x_median = median(:x))
```
"""
macro combine(data::Symbol, exprs...)
  splits   = map(expr -> _split(expr, false), exprs)
  colnames = first.(splits)
  colexprs = last.(splits)
  escdata  = esc(data)
  quote
    if $escdata isa Partition
      local partition = $escdata
      _combine(partition, [$(colnames...)], [$(map(_partexpr, colexprs)...)])
    else
      local data = $escdata
      _combine(data, [$(colnames...)], [$(map(_dataexpr, colexprs)...)])
    end
  end
end

function _combine(data::D, names, columns) where {D<:Data}
  dom   = domain(data)
  table = values(data)

  newdom = Collection([centroid(dom)])

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

function _combine(partition::Partition{D}, names, columns) where {D<:Data}
  table = values(partition.object)
  meta  = metadata(partition)

  point(data) = centroid(boundingbox(domain(data)))

  newdom = Collection([point(data) for data in partition])

  grows    = meta[:rows]
  gnames   = meta[:names]
  gcolumns = [[row[i] for row in grows] for i in 1:length(gnames)]

  newnames   = vcat(gnames, names)
  newcolumns = vcat(gcolumns, columns)

  𝒯 = (; zip(newnames, newcolumns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

# utils
_partexpr(colexpr) = :([$colexpr for data in partition])
_dataexpr(colexpr) = :([$colexpr])

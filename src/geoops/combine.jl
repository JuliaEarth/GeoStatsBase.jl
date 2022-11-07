# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @combine(data, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)
    @combine(group, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

docstring...

# Examples

```julia
using Statistics

@combine(data, :x_sum = sum(:x))
@combine(data, :x_mean = mean(:x))

group = @groupby(data, :y)
@combine(group, :x_prod = prod(:x))
@combine(group, :x_median = median(:x))
```
"""
macro combine(data::Symbol, exprs...)
  splits   = map(expr -> _split(expr, false), exprs)
  colnames = first.(splits)
  colexprs = last.(splits)
  escdata  = esc(data)
  quote
    if $escdata isa Partition
      local group = $escdata
      _combine(group, [$(colnames...)], [$(map(_groupexpr, colexprs)...)])
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

function _combine(group::Partition{D}, names, columns) where {D<:Data}
  table = values(group.object)

  newdom = Collection([centroid(domain(data)) for data in group])

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

# utils
_groupexpr(colexpr) = :([$colexpr for data in group])
_dataexpr(colexpr) = :([colexpr])

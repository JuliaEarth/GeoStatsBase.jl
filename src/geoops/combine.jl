# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @combine(data, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

Returns geospatial `data` with columns `:col₁`, `:col₂`, ..., `:colₙ`
computed with reduction expressions `expr₁`, `expr₂`, ..., `exprₙ`. 

See also: [`@groupby`](@ref).

# Examples

```julia
@combine(data, :x_sum = sum(:x))
@combine(data, :x_mean = mean(:x))

groups = @groupby(data, :y)
@combine(groups, :x_prod = prod(:x))
@combine(groups, :x_median = median(:x))

@combine(data, {"z"} = sum({"x"}) + prod({"y"}))
xnm, ynm, znm = :x, :y, :z
@combine(data, {znm} = sum({xnm}) + prod({ynm}))
```
"""
macro combine(object::Symbol, exprs...)
  splits = map(expr -> _split(expr, false), exprs)
  colnames = first.(splits)
  colexprs = last.(splits)
  escobj = esc(object)
  quote
    if $escobj isa Partition
      local partition = $escobj
      _combine(partition, [$(colnames...)], [$(map(_partexpr, colexprs)...)])
    else
      local data = $escobj
      _combine(data, [$(colnames...)], [$(map(_dataexpr, colexprs)...)])
    end
  end
end

function _combine(data::D, names, columns) where {D<:AbstractGeoTable}
  table = values(data)

  newdom = GeometrySet([Multi(domain(data))])

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

function _combine(partition::Partition{D}, names, columns) where {D<:AbstractGeoTable}
  table = values(parent(partition))
  meta = metadata(partition)

  newdom = GeometrySet([Multi(domain(data)) for data in partition])

  grows = meta[:rows]
  gnames = meta[:names]
  gcolumns = [[row[i] for row in grows] for i in 1:length(gnames)]

  newnames = vcat(gnames, names)
  newcolumns = vcat(gcolumns, columns)

  𝒯 = (; zip(newnames, newcolumns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

# utils
_partexpr(colexpr) = :([$colexpr for data in partition])
_dataexpr(colexpr) = :([$colexpr])

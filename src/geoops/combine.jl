# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @combine(geotable, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

Returns a geotable with columns `:col₁`, `:col₂`, ..., `:colₙ` computed
with reduction expressions `expr₁`, `expr₂`, ..., `exprₙ`. 

See also: [`@groupby`](@ref).

# Examples

```julia
@combine(geotable, :x_sum = sum(:x))
@combine(geotable, :x_mean = mean(:x))

p = @groupby(geotable, :y)
@combine(p, :x_prod = prod(:x))
@combine(p, :x_median = median(:x))

@combine(geotable, {"z"} = sum({"x"}) + prod({"y"}))
xnm, ynm, znm = :x, :y, :z
@combine(geotable, {znm} = sum({xnm}) + prod({ynm}))
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

function _combine(geotable::GT, names, columns) where {GT<:AbstractGeoTable}
  table = values(geotable)

  newdom = GeometrySet([Multi(domain(geotable))])

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(GT)(newdom, vals)
end

function _combine(partition::Partition{GT}, names, columns) where {GT<:AbstractGeoTable}
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
  constructor(GT)(newdom, vals)
end

# utils
_partexpr(colexpr) = :([$colexpr for data in partition])
_dataexpr(colexpr) = :([$colexpr])

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @combine(data, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

Returns geospatial `data` with columns `:col₁`, `:col₂`, ..., `:colₙ`
computed with reduction expressions `expr₁`, `expr₂`, ..., `exprₙ`.

If a reduction expression is not defined for the `:geometry` column,
the geometries will be aggregated using `Multi`.

See also: [`@groupby`](@ref).

# Examples

```julia
@combine(data, :x_sum = sum(:x))
@combine(data, :x_mean = mean(:x))
@combine(data, :x_mean = mean(:x), :geometry = centroid(:geometry))

groups = @groupby(data, :y)
@combine(groups, :x_prod = prod(:x))
@combine(groups, :x_median = median(:x))
@combine(groups, :x_median = median(:x), :geometry = centroid(:geometry))

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

  newdom = if :geometry ∈ names
    i = findfirst(==(:geometry), names)
    popat!(names, i)
    geoms = popat!(columns, i)
    GeometrySet(geoms)
  else
    GeometrySet([Multi(domain(data))])
  end

  newtable = if isempty(names)
    nothing
  else
    𝒯 = (; zip(names, columns)...)
    𝒯 |> Tables.materializer(table)
  end

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

function _combine(partition::Partition{D}, names, columns) where {D<:AbstractGeoTable}
  table = values(parent(partition))
  meta = metadata(partition)

  newdom = if :geometry ∈ names
    i = findfirst(==(:geometry), names)
    popat!(names, i)
    geoms = popat!(columns, i)
    GeometrySet(geoms)
  else
    GeometrySet([Multi(domain(data)) for data in partition])
  end

  grows = meta[:rows]
  gnames = meta[:names]
  gcolumns = Any[[row[i] for row in grows] for i in 1:length(gnames)]
  append!(gnames, names)
  append!(gcolumns, columns)

  𝒯 = (; zip(gnames, gcolumns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

# utils
_partexpr(colexpr) = :([$colexpr for data in partition])
_dataexpr(colexpr) = :([$colexpr])

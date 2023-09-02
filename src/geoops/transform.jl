# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    @transform(data, :col₁ = expr₁, :col₂ = expr₂, ..., :colₙ = exprₙ)

Returns geospatial `data` with columns `col₁`, `col₂`, ..., `colₙ`
computed with expressions `expr₁`, `expr₂`, ..., `exprₙ`.

See also: [`@groupby`](@ref).

# Examples

```julia
@transform(data, :z = :x + 2*:y)
@transform(data, :w = :x^2 - :y^2)
@transform(data, :sinx = sin(:x), :cosy = cos(:y))

groups = @groupby(data, :y)
@transform(groups, :logx = log(:x))
@transform(groups, :expz = exp(:z))

@transform(data, {"z"} = {"x"} - 2*{"y"})
xnm, ynm, znm = :x, :y, :z
@transform(data, {znm} = {xnm} - 2*{ynm})
```
"""
macro transform(object::Symbol, exprs...)
  splits = map(expr -> _split(expr), exprs)
  colnames = first.(splits)
  colexprs = last.(splits)
  escobj = esc(object)
  quote
    if $escobj isa Partition
      local partition = $escobj
      local data = parent(partition)
      _transform(partition, [$(colnames...)], [$(colexprs...)])
    else
      local data = $escobj
      _transform(data, [$(colnames...)], [$(colexprs...)])
    end
  end
end

function _transform(data::D, tnames, tcolumns) where {D<:AbstractGeoTable}
  dom = domain(data)
  table = values(data)

  cols = Tables.columns(table)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  newdom = dom
  for (nm, col) in zip(tnames, tcolumns)
    if nm == :geometry
      newdom = GeometrySet(col)
    elseif nm ∈ names
      i = findfirst(==(nm), names)
      columns[i] = col
    else
      push!(names, nm)
      push!(columns, col)
    end
  end

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)

  vals = Dict(paramdim(newdom) => newtable)
  constructor(D)(newdom, vals)
end

function _transform(partition::Partition{D}, tnames, tcolumns) where {D<:AbstractGeoTable}
  data = parent(partition)
  inds = indices(partition)
  meta = metadata(partition)

  if !isdisjoint(tnames, meta[:names])
    throw(ArgumentError("Cannot replace group columns"))
  end

  newdata = _transform(data, tnames, tcolumns)
  Partition(newdata, inds, meta)
end

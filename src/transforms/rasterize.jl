# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rasterize(grid)
    Rasterize(grid, var₁ => agg₁, ..., varₙ => aggₙ)

Rasterize geometries within specified `grid`.

    Rasterize(nx, ny)
    Rasterize(nx, ny, var₁ => agg₁, ..., varₙ => aggₙ)

Alternatively, use the grid with size `nx` by `ny`
obtained with discretization of the bounding box.

Duplicates of a variable `varᵢ` are aggregated with
aggregation function `aggᵢ`. If an aggregation function 
is not defined for variable `varᵢ`, the default aggregation 
function will be used. Default aggregation function is `mean` for
continuous variables and `first` otherwise.

# Examples

```julia
grid = CartesianGrid(10, 10)
Rasterize(grid)
Rasterize(10, 10)
Rasterize(grid, 1 => last, 2 => maximum)
Rasterize(10, 10, 1 => last, 2 => maximum)
Rasterize(grid, :a => first, :b => minimum)
Rasterize(10, 10, :a => first, :b => minimum)
Rasterize(grid, "a" => last, "b" => maximum)
Rasterize(10, 10, "a" => last, "b" => maximum)
```
"""
struct Rasterize{T<:Union{Grid{2},Dims{2}},S<:ColSpec,} <: TableTransform
  grid::T
  colspec::S
  aggfuns::Vector{Function}
end

Rasterize(grid::Grid{2}) = Rasterize(grid, NoneSpec(), Function[])
Rasterize(nx::Int, ny::Int) = Rasterize((nx, ny), NoneSpec(), Function[])

Rasterize(grid::Grid{2}, pairs::Pair{C,<:Function}...) where {C<:Col} =
  Rasterize(grid, colspec(first.(pairs)), collect(Function, last.(pairs)))

Rasterize(nx::Int, ny::Int, pairs::Pair{C,<:Function}...) where {C<:Col} =
  Rasterize((nx, ny), colspec(first.(pairs)), collect(Function, last.(pairs)))

isrevertible(::Type{<:Rasterize}) = true

_grid(grid::Grid{2}, dom) = grid
_grid(dims::Dims{2}, dom) = CartesianGrid(extrema(boundingbox(dom))...; dims)

function apply(transform::Rasterize, geotable::AbstractGeoTable)
  dom = domain(geotable)
  tab = values(geotable)
  cols = Tables.columns(tab)
  vars = Tables.columnnames(cols)
  types = Tables.schema(tab).types

  grid = _grid(transform.grid, dom)
  ncols = length(sch.names)
  nrows = nelements(grid)

  # aggregation functions
  svars = choose(transform.colspec, vars)
  agg = Dict(zip(svars, transform.aggfuns))
  for var in vars
    if !haskey(agg, var)
      v = Tables.getcolumn(cols, var)
      agg[var] = defaultagg(v)
    end
  end

  mask = zeros(Int, nrows)
  rows = [[T[] for T in types] for _ in 1:nrows]
  for (ind, geom) in enumerate(dom)
    for i in indices(grid, geom)
      mask[i] = ind
      row = Tables.subset(tab, ind)
      for j in 1:ncols
        v = Tables.getcolumn(row, j)
        push!(rows[i][j], v)
      end
    end
  end

  # generate grid column
  function gencol(j, var)
    map(1:nrows) do i
      vs = rows[i][j]
      if isempty(vs)
        missing
      elseif length(vs) == 1
        first(vs)
      else
        agg[var](vs)
      end
    end
  end

  # construct new table
  pairs = (var => gencol(j, var) for (j, var) in enumerate(vars))
  newtab = (; pairs...) |> Tables.materializer(tab)

  # new spatial data
  newgeotable = georef(newtab, grid)

  newgeotable, mask
end

function revert(::Rasterize, newgeotable::AbstractGeoTable, cache)
  dom = domain(newgeotable)
  tab = values(newgeotable)
  cols = Tables.columns(tab)
  names = Tables.columnnames(cols)

  mask = :mask
  # make unique
  while mask ∈ names
    mask = Symbol(mask, :_)
  end
  pairs = (nm => Tables.getcolumn(cols, nm) for nm in names)
  newtab = (; mask => cache, pairs...)
  newgtb = georef(newtab, dom)

  newgtb |> Potrace(mask) |> Filter(row -> row[mask] > 0) |> Reject(mask)
end

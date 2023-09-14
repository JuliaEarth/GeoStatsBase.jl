# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rasterize(grid)
    Rasterize(nx, ny)

TODO
"""
struct Rasterize{T<:Union{Grid{2},Dims{2}}} <: StatelessTableTransform
  grid::T
end

Rasterize(nx::Int, ny::Int) = Rasterize((nx, ny))

isrevertible(::Type{<:Rasterize}) = true

_grid(grid::Grid{2}, dom) = grid
_grid(dims::Dims{2}, dom) = CartesianGrid(extrema(boundingbox(dom))...; dims)

function apply(transform::Rasterize, geotable::AbstractGeoTable)
  dom = domain(geotable)
  tab = values(geotable)
  sch = Tables.schema(tab)
  grid = _grid(transform.grid, dom)
  ncols = length(sch.names)
  nrows = nelements(grid)

  cache = zeros(nrows)
  rows = [[T[] for T in sch.types] for _ in 1:nrows]
  for (ind, geom) in enumerate(dom)
    for i in indices(grid, geom)
      cache[i] = ind
      row = Tables.subset(tab, i)
      for j in 1:ncols
        v = Tables.getcolumn(row, j)
        push!(rows[i][j], v)
      end
    end
  end

  # generate grid column
  function gencol(j)
    map(1:nrows) do i
      vs = rows[i][j]
      if isempty(vs)
        missing
      elseif length(vs) == 1
        first(vs)
      else
        agg = defaultagg(vs)
        agg(vs)
      end
    end
  end

  # construct new table
  pairs = (nm => gencol(j) for (j, nm) in enumerate(sch.names))
  newtab = (; pairs...) |> Tables.materializer(tab)

  # new spatial data
  newgtb = georef(newtab, grid)

  newgtb, cache
end

function revert(::Rasterize, geotable::AbstractGeoTable, cache)
  dom = domain(geotable)
  tab = values(geotable)
  cols = Tables.columns(tab)
  names = Tables.columnnames(cols)

  # column with geometry indices
  geomind = :__GEOMETRY_INDEX__
  # make unique
  while geomind ∈ names
    geomind = Symbol(geomind, :_)
  end

  pairs = (nm => Tables.getcolumn(cols, nm) for nm in names)
  newtab = (; geomind => cache, pairs...)
  newgtb = georef(newtab, dom)
  Potrace(geomind)(newgtb)
end

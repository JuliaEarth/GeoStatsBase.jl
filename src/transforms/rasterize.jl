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

isrevertible(::Type{<:Rasterize}) = false

_grid(grid::Grid{2}, dom) = grid
_grid(dims::Dims{2}, dom) = CartesianGrid(extrema(boundingbox(dom))...; dims)

function apply(transform::Rasterize, geotable::AbstractGeoTable)
  dom = domain(geotable)
  tab = values(geotable)
  cols = Tables.columns(tab)
  vars = Tables.columnnames(cols)
  grid = _grid(transform.grid, dom)

  # get grid indices of each domain index
  gridinds = mapreduce(vcat, enumerate(dom)) do (i, geom)
    i .=> indices(grid, geom)
  end

  # map each grid index with 0 or more domain indices
  dominds = Dict(gind => Int[] for gind in 1:nelements(grid))
  for (i, gind) in gridinds
    push!(dominds[gind], i)
  end

  # generate grid column
  function gencol(var)
    v = Tables.getcolumn(tab, var)
    map(1:nelements(grid)) do gind
      inds = dominds[gind]
      if isempty(inds)
        missing
      elseif length(inds) == 1
        # copy value
        v[inds[1]]
      else
        # aggregate values
        agg = defaultagg(v)
        agg(v[inds])
      end
    end
  end

  # construct new table
  𝒯 = (; (var => gencol(var) for var in vars)...)
  newtab = 𝒯 |> Tables.materializer(tab)

  # new data tables
  newvals = Dict(paramdim(grid) => newtab)

  # new spatial data
  newdata = constructor(geotable)(grid, newvals)

  newdata, nothing
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    inside(object, geometry)

Return all locations of `object` that are inside `geometry`.
"""
function inside(object, geom)
  N = ncoords(object)
  T = coordtype(object)

  x = MVector{N,T}(undef)

  inds = Vector{Int}()
  for i in 1:nelms(object)
    coordinates!(x, object, i)
    x ∈ geom && push!(inds, i)
  end

  collect(view(object, inds))
end

# regular grid + rectangle
function inside(grid::RegularGrid, rect::Rectangle)
  ilo, iup = _corners(grid, rect)
  _subgrid(grid, ilo, iup)
end

function inside(sdata::SpatialData{T,N,𝒟,𝒯},
                rect::Rectangle) where {T,N,𝒟<:RegularGrid,𝒯}
  grid  = domain(sdata)
  table = values(sdata)

  # row view of table
  ctor = Tables.materializer(table)
  rows = Tables.rows(table)

  # retrieve subgrid
  ilo, iup = _corners(grid, rect)
  𝒟ᵢ = _subgrid(grid, ilo, iup)

  # retrieve subtable
  inds = vec(LinearIndices(size(grid))[ilo:iup])
  𝒯ᵢ = ctor(rows[inds])

  georef(𝒯ᵢ, 𝒟ᵢ)
end

function _corners(grid::RegularGrid, rect::Rectangle)
  or = origin(grid)
  sp = spacing(grid)
  sz = size(grid)

  # lower left and upper right
  lo,  up  = or, @. or + (sz - 1)*sp
  rlo, rup = extrema(rect)

  # Cartesian indices of new corners
  ilo = @. max(ceil(Int, (rlo - lo) / sp) + 1, 1)
  iup = @. min(floor(Int, (rup - lo) / sp) + 1, sz)

  CartesianIndex(Tuple(ilo)), CartesianIndex(Tuple(iup))
end

function _subgrid(grid::RegularGrid, ilo, iup)
  linear = LinearIndices(size(grid))
  orig   = coordinates(grid, linear[ilo])
  dims   = Dims(@. iup.I - ilo.I + 1)
  spac   = spacing(grid)
  RegularGrid(dims, orig, spac)
end
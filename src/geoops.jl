# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    inside(object, geometry)

Return all locations of `object` that are inside `geometry`.
"""
function inside(object, geom::AbstractGeometry)
  N = ndims(object)
  T = coordtype(object)

  x = MVector{N,T}(undef)

  inds = Vector{Int}()
  for i in 1:npoints(object)
    coordinates!(x, object, i)
    x ∈ geom && push!(inds, i)
  end

  collect(view(object, inds))
end

# regular grid + rectangle
function inside(grid::RegularGrid, rect::Rectangle)
  or = origin(grid)
  sp = spacing(grid)
  sz = size(grid)
  ro = origin(rect)
  rs = sides(rect)

  # lower left and upper right
  lo,  up  = or, @. or + (sz - 1)*sp
  rlo, rup = ro, @. ro + rs

  # Cartesian indices of new corners
  ilo = @. ceil(Int, (rlo - lo) / sp)
  iup = @. min(floor(Int, (rup - lo) / sp), sz)

  # corners in real coordinates
  linear = LinearIndices(sz)
  start  = coordinates(grid, linear[ilo...])
  finish = coordinates(grid, linear[iup...])
  dims   = @. iup - ilo + 1

  RegularGrid(Tuple(start), Tuple(finish), dims=Tuple(dims))
end
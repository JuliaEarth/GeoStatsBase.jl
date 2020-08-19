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
  ilo = @. max(ceil(Int, (rlo - lo) / sp) + 1, 1)
  iup = @. min(floor(Int, (rup - lo) / sp) + 1, sz)

  # corners in real coordinates
  linear = LinearIndices(sz)
  orig   = coordinates(grid, linear[ilo...])
  dims   = Dims(@. iup - ilo + 1)

  RegularGrid(dims, orig, sp)
end
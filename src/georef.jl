# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialData(domain, data)

Tabular `data` georeferenced in a spatial `domain`.
"""
struct SpatialData{T,N,𝒟,𝒯} <: AbstractData{T,N}
  domain::𝒟
  table::𝒯
end

function SpatialData(domain, table)
  nd = npoints(domain)
  nt = length(Tables.rows(table))
  @assert nd == nt "number of rows ≠ number of points"
  T = coordtype(domain)
  N = ndims(domain)
  𝒟 = typeof(domain)
  𝒯 = typeof(table)
  SpatialData{T,N,𝒟,𝒯}(domain, table)
end

"""
    georef(table, domain)

Georeference `table` on spatial `domain`.
"""
georef(table, domain) = SpatialData(domain, table)

georef(table, coords::AbstractMatrix) = georef(table, PointSet(coords))

function georef(table, coordnames::NTuple)
  cols = Tables.columntable(table)
  @assert coordnames ⊆ keys(cols) "invalid coordinates for table"
  vars = filter(c->c[1] ∉ coordnames, pairs(cols))
  coords = reduce(hcat, [cols[cname] for cname in coordnames])
  georef(DataFrame(vars), PointSet(coords'))
end

georef(tuple::NamedTuple, domain) =
  georef(DataFrame([var=>vec(val) for (var,val) in pairs(tuple)]), domain)

georef(tuple::NamedTuple, coords::AbstractMatrix) = georef(tuple, PointSet(coords))

georef(tuple, origin, spacing) = georef(tuple, RegularGrid(size(tuple[1]), origin, spacing))

georef(tuple) = georef(tuple, ntuple(i->0., ndims(tuple[1])), ntuple(i->1., ndims(tuple[1])))

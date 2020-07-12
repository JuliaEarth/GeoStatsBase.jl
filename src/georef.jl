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

"""
    georef(table, coords)

Georeference `table` on a `PointSet(coords)`.
"""
georef(table, coords::AbstractMatrix) = georef(table, PointSet(coords))

"""
    georef(table, coordnames)

Georeference `table` using columns `coordnames`.
"""
function georef(table, coordnames::NTuple)
  cols = Tables.columntable(table)
  @assert coordnames ⊆ keys(cols) "invalid coordinates for table"
  @assert !(keys(cols) ⊆ coordnames) "table must have at least one variable"
  vars = filter(c->c[1] ∉ coordnames, pairs(cols))
  coords = reduce(hcat, [cols[cname] for cname in coordnames])
  georef(DataFrame(vars), PointSet(coords'))
end

"""
    georef(tuple, domain)

Georeference named `tuple` on spatial `domain`.
"""
georef(tuple::NamedTuple, domain) =
  georef(DataFrame([var=>vec(val) for (var,val) in pairs(tuple)]), domain)

"""
    georef(tuple, coords)

Georefrence named `tuple` on `PointSet(coords)`.
"""
georef(tuple::NamedTuple, coords::AbstractMatrix) = georef(tuple, PointSet(coords))

"""
    georef(tuple, origin, spacing)

Georeference named `tuple` on `RegularGrid(size(tuple[1]), origin, spacing)`.
"""
georef(tuple, origin, spacing) = georef(tuple, RegularGrid(size(tuple[1]), origin, spacing))

"""
    georef(tuple)

Georeference named `tuple` on `RegularGrid` with `origin=(0.,0.,...)` and
with `spacing=(1.,1.,...)`.
"""
georef(tuple) = georef(tuple, ntuple(i->0., ndims(tuple[1])), ntuple(i->1., ndims(tuple[1])))

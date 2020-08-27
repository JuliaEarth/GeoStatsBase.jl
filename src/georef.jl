# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    georef(table, domain)

Georeference `table` on spatial `domain`.
"""
georef(table, domain) = SpatialData(domain, table)

"""
    georef(table, coords)

Georeference `table` on a `PointSet(coords)`.
"""
georef(table, coords::AbstractVecOrMat) = georef(table, PointSet(coords))

"""
    georef(table, coordnames)

Georeference `table` using columns `coordnames`.
"""
function georef(table, coordnames::NTuple)
  ctor = Tables.materializer(table)
  colnames = Tables.columnnames(table)
  @assert coordnames ⊆ colnames "invalid coordinates for table"
  @assert !(colnames ⊆ coordnames) "table must have at least one variable"
  varnames = setdiff(colnames, coordnames)
  vars = [v => Tables.getcolumn(table, v) for v in varnames]
  coords = reduce(hcat, [Tables.getcolumn(table, c) for c in coordnames])
  georef(ctor(vars), coords')
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
georef(tuple::NamedTuple, coords::AbstractVecOrMat) = georef(tuple, PointSet(coords))

"""
    georef(tuple; origin=(0.,0.,...), spacing=(1.,1.,...))

Georeference named `tuple` on `RegularGrid(size(tuple[1]), origin, spacing)`.
"""
georef(tuple;
       origin=ntuple(i->0., ndims(tuple[1])),
       spacing=ntuple(i->1., ndims(tuple[1]))) = georef(tuple, origin, spacing)

georef(tuple, origin, spacing) =
  georef(tuple, RegularGrid(size(tuple[1]), origin, spacing))

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    georef(table, domain)

Georeference `table` on `domain`.

`table` must implement the [Tables.jl](https://github.com/JuliaData/Tables.jl)
interface (e.g., `DataFrame`, `CSV.File`, `XLSX.Worksheet`).

`domain` must implement the [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl)
interface (e.g., `CartesianGrid`, `SimpleMesh`, `GeometrySet`).

## Examples

```julia
julia> georef((a=rand(100), b=rand(100)), CartesianGrid(10, 10))
```
"""
georef(table, domain) = geotable(domain, etable=table)

"""
    georef(table, geoms)

Georeference `table` on vector of geometries `geoms`.

`geoms` must implement the [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl)
interface (e.g., `Point`, `Quadrangle`, `Hexahedron`).

## Examples

```julia
julia> georef((a=rand(10), b=rand(10)), rand(Point2, 10))
```
"""
georef(table, geoms::AbstractVector{<:Geometry}) = georef(table, GeometrySet(geoms))

"""
    georef(table, coords)

Georeference `table` on `PointSet(coords)`.

## Examples

```julia
julia> georef((a=rand(10), b=rand(10)), rand(2, 10))
```
"""
georef(table, coords::AbstractVecOrMat) = georef(table, PointSet(coords))

"""
    georef(table, names)

Georeference `table` using column `names`.

## Examples

```julia
julia> georef((a=rand(10), x=rand(10), y=rand(10)), (:x, :y))
```
"""
function georef(table, names::NTuple)
  colnames = Tables.columnnames(table)
  @assert names ⊆ colnames "invalid column names for table"
  @assert !(colnames ⊆ names) "table must have at least one variable"
  vars = setdiff(colnames, names)
  vtable = table |> Select(vars)
  ctable = table |> Select(names)
  coords = Tuple.(Tables.rowtable(ctable))
  georef(vtable, coords)
end

function georef(tuple::NamedTuple, domain)
  flat = (; (var => vec(val) for (var, val) in pairs(tuple))...)
  georef(TypedTables.Table(flat), domain)
end

# fix ambiguity between other methods
georef(tuple::NamedTuple, geoms::AbstractVector{<:Geometry}) = georef(tuple, GeometrySet(geoms))

georef(tuple::NamedTuple, coords::AbstractVecOrMat) = georef(tuple, PointSet(coords))

# fix ambiguity between other methods
georef(tuple::NamedTuple, names::NTuple) = georef(TypedTables.Table(tuple), names)

"""
    georef(tuple)

Georeference named `tuple` on `CartesianGrid(size(first(tuple)))`.

## Examples

```julia
julia> georef((a=rand(10, 10), b=rand(10, 10))) # 2D grid
julia> georef((a=rand(10, 10, 10), b=rand(10, 10, 10))) # 3D grid
```
"""
georef(tuple) = georef(tuple, CartesianGrid(size(first(tuple))))

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    readgeotable(args; coordnames=(:x,:y,:z), kwargs)

Read data from disk using `CSV.File`, optionally specifying
the columns `coordnames` with spatial coordinates.

The arguments `args` and keyword arguments `kwargs` are
forwarded to the `CSV.File` function, please check their
documentation for more details.
"""
readgeotable(args...; coordnames=(:x,:y,:z), kwargs...) =
  georef(DataFrame!(CSV.File(args...; kwargs...)), coordnames)

"""
    split(object, fraction, [normal])

Split spatial `object` into two parts where the first
part has a `fraction` of the elements. Optionally, the
split is performed perpendicular to a `normal` direction.
"""
function split(object, fraction::Real, normal=nothing)
  if isnothing(normal)
    partition(object, FractionPartitioner(fraction))
  else
    partition(object, BisectFractionPartitioner(normal, fraction))
  end
end

"""
    groupby(sdata, var)

Partition spatial data `sdata` into groups of constant value
for spatial variable `var`.

### Notes

Missing values are grouped into a separate group.
"""
groupby(sdata::AbstractData, var::Symbol) =
  partition(sdata, VariablePartitioner(var))

"""
    boundbox(object)

Return the minimum axis-aligned bounding rectangle of the spatial `object`.

### Notes

Equivalent to `cover(object, RectangleCoverer())`
"""
boundbox(object) = cover(object, RectangleCoverer())

"""
    sample(object, nsamples, [weights], replace=false)

Generate `nsamples` samples from spatial `object`
uniformly or using `weights`, with or without
replacement depending on `replace` option.
"""
function sample(object::Union{AbstractDomain,AbstractData}, nsamples::Int,
                weights::AbstractVector=[]; replace=false)
  if isempty(weights)
    sample(object, UniformSampler(nsamples, replace))
  else
    sample(object, WeightedSampler(nsamples, weights, replace))
  end
end

"""
    filter(pred, sdata)

Retain all locations in spatial data `sdata` according to
a predicate function `pred`. A predicate function takes
table rows as input, e.g. `pred(r) = r.state == "CA"`.
"""
function filter(pred, sdata::AbstractData)
  𝒯 = values(sdata)
  𝒟 = domain(sdata)

  # row table view
  ctor = Tables.materializer(𝒯)
  rows = Tables.rows(𝒯)

  # indices to retain
  inds = findall(pred, rows)

  # return point set
  table = ctor(rows[inds])
  coord = coordinates(𝒟, inds)

  georef(table, coord)
end

"""
    slice(object, xmin:xmax, ymin:ymax, ...)

Slice spatial `object` using real coordinate ranges
`xmin:xmax`, `ymin:ymax`, ...
"""
slice(object, ranges::Vararg) =
  inside(object, Rectangle(first.(ranges), last.(ranges)))

"""
    spheredir(θ, φ)

Returns the 3D direction given polar angle `θ` and
azimuthal angle `φ` in degrees according to the ISO
convention.
"""
function spheredir(theta, phi)
  θ, φ = deg2rad(theta), deg2rad(phi)
  SVector(sin(θ)*cos(φ), sin(θ)*sin(φ), cos(θ))
end

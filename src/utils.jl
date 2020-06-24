# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    readgeotable(args; coordnames=[:x,:y,:z], kwargs)

Read data from disk using `CSV.read`, optionally specifying
the columns `coordnames` with spatial coordinates.

The arguments `args` and keyword arguments `kwargs` are
forwarded to the `CSV.read` function, please check their
documentation for more details.

This function returns a [`GeoDataFrame`](@ref) object.
"""
readgeotable(args...; coordnames=[:x,:y,:z], kwargs...) =
  GeoDataFrame(read(args...; kwargs...), coordnames)

"""
    split(object, fraction, [normal])

Split spatial `object` into two parts where the first
part has a `fraction` of the total volume. The split
is performed along a `normal` direction. The default
direction is aligned with the first spatial dimension
of the object.
"""
function Base.split(object::AbstractSpatialObject,
                    fraction::Real, normal=nothing)
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
boundbox(object::AbstractSpatialObject) = cover(object, RectangleCoverer())

"""
    sample(object, nsamples, [weights], replace=false)

Generate `nsamples` samples from spatial `object`
uniformly or using `weights`, with or without
replacement depending on `replace` option.
"""
function sample(object::AbstractSpatialObject, nsamples::Int,
                weights::AbstractVector=[]; replace=false)
  if isempty(weights)
    sample(object, UniformSampler(nsamples, replace))
  else
    sample(object, WeightedSampler(nsamples, weights, replace))
  end
end

"""
    join(sdata₁, sdata₂)

Join variables in spatial data `sdata₁` and `sdata₂`.
"""
Base.join(sdata₁::AbstractData, sdata₂::AbstractData) =
  join(sdata₁, sdata₂, VariableJoiner())

"""
    uniquecoords(sdata; aggreg=Dict())

Filter spatial data `sdata` to produce a new data
set with unique coordinates.

See [`UniqueCoordsFilter`](@ref) for more details.
"""
uniquecoords(sdata::AbstractData; aggreg=Dict()) =
  filter(sdata, UniqueCoordsFilter(aggreg))

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

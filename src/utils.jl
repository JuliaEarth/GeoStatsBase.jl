# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
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
  georef(DataFrame(CSV.File(args...; kwargs...)), coordnames)

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

"""
    aniso2distance(semiaxes, angles; convention=:TaitBryanExtr)

Return the distance associated with the ellipsoid with given `semiaxes`,
`angles` and `convention`. See [`Ellipsoid`](@ref).
"""
aniso2distance(semiaxes, angles; convention=:TaitBryanExtr) =
  metric(Ellipsoid(semiaxes, angles, convention=convention))

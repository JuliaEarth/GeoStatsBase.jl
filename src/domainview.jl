# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpatialDomainView(domain, inds)

Return a view of `domain` at `inds`.
"""
struct SpatialDomainView
  domain
  inds
end

geotrait(::SpatialDomainView) = GeoDomain()
nelms(dv::SpatialDomainView) = length(dv.inds)
ncoords(dv::SpatialDomainView) = ncoords(dv.domain)
coordtype(dv::SpatialDomainView) = coordtype(dv.domain)
coordinates!(buff::AbstractVector, dv::SpatialDomainView, ind::Int) =
  coordinates!(buff, dv.domain, dv.inds[ind])

Base.collect(dv::SpatialDomainView) = PointSet(coordinates(dv))

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::SpatialDomainView)
  N = ncoords(dv)
  T = coordtype(dv)
  npts = nelms(dv)
  print(io, "$npts SpatialDomainView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::SpatialDomainView)
  println(io, dv)
  Base.print_array(io, coordinates(dv))
end

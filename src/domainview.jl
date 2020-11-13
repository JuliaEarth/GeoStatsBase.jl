# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DomainView(domain, inds)

Return a view of `domain` at `inds`.
"""
struct DomainView{𝒟,I} <: AbstractDomain
  domain::𝒟
  inds::I
end

nelms(dv::DomainView) = length(dv.inds)
ncoords(dv::DomainView) = ncoords(dv.domain)
coordtype(dv::DomainView) = coordtype(dv.domain)
coordinates!(buff::AbstractVector, dv::DomainView, ind::Int) =
  coordinates!(buff, dv.domain, dv.inds[ind])

Base.collect(dv::DomainView) = PointSet(coordinates(dv))

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::DomainView)
  N = ncoords(dv)
  T = coordtype(dv)
  npts = nelms(dv)
  print(io, "$npts DomainView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::DomainView)
  println(io, dv)
  Base.print_array(io, coordinates(dv))
end
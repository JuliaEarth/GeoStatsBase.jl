# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DomainView(domain, inds)

Return a view of `domain` at `inds`.
"""
struct DomainView{T,N} <: AbstractDomain{T,N}
  domain
  inds
end

DomainView(domain, inds) =
  DomainView{coordtype(domain),ndims(domain)}(domain, inds)

npoints(dv::DomainView) = length(dv.inds)

coordinates!(buff::AbstractVector, dv::DomainView, ind::Int) =
  coordinates!(buff, dv.domain, dv.inds[ind])

Base.collect(dv::DomainView) = PointSet(coordinates(dv))

# ------------
# IO methods
# ------------
function Base.show(io::IO, dv::DomainView)
  N = ndims(dv)
  T = coordtype(dv)
  npts = npoints(dv)
  print(io, "$npts DomainView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::DomainView)
  println(io, dv)
  Base.print_array(io, coordinates(dv))
end

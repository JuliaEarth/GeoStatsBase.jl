# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DomainView(domain, locations)

Return a view of `domain` at `locations`.

### Notes

This type implements the `AbstractDomain` interface.
"""
struct DomainView{T,N,
                  D<:AbstractDomain{T,N},
                  I<:AbstractVector{Int}} <: AbstractDomain{T,N}
  domain::D
  locations::I
end

npoints(dv::DomainView) = length(dv.locations)

coordinates!(buff::AbstractVector, dv::DomainView, location::Int) =
  coordinates!(buff, dv.domain, dv.locations[location])

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

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    DomainView(domain, locations)

Return a view of `domain` at `locations`.

### Notes

This type implements the `AbstractDomain` interface.
"""
struct DomainView{T<:Real,N,
                  D<:AbstractDomain{T,N},
                  I<:AbstractVector{Int}} <: AbstractDomain{T,N}
  domain::D
  locations::I
end

npoints(view::DomainView) = length(view.locations)

coordinates!(buff::AbstractVector, view::DomainView, location::Int) =
  coordinates!(buff, view.domain, view.locations[location])

# ------------
# IO methods
# ------------
function Base.show(io::IO, view::DomainView{T,N,D,I}) where {T<:Real,N,
                                                             D<:AbstractDomain{T,N},
                                                             I<:AbstractVector{Int}}
  npts = npoints(view)
  print(io, "$npts DomainView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", view::DomainView)
  println(io, view)
  Base.print_array(io, coordinates(view))
end

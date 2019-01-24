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

Base.ndims(view::DomainView) = ndims(view.domain)

coordtype(view::DomainView) = coordtype(view.domain)

npoints(view::DomainView) = length(view.locations)

coordinates!(buff::AbstractVector, view::DomainView, location::Int) =
  coordinates!(buff, view.domain, view.locations[location])

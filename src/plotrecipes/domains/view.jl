# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(dv::SpatialDomainView, data::AbstractVector)
  @series begin
    collect(dv), data
  end
end

@recipe function f(dv::SpatialDomainView)
  @series begin
    collect(dv)
  end
end

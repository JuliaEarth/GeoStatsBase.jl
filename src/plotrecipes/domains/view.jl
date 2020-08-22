# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(dv::DomainView, data::AbstractVector)
  @series begin
    collect(dv), data
  end
end

@recipe function f(dv::DomainView)
  @series begin
    collect(dv)
  end
end

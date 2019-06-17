# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(domain::AbstractDomain, data::AbstractVector) where {N,T}
  @series begin
    PointSet(coordinates(domain)), data
  end
end

@recipe function f(domain::AbstractDomain)
  @series begin
    PointSet(coordinates(domain))
  end
end

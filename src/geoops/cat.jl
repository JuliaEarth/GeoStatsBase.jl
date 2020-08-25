# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    vcat(𝒟₁, 𝒟₂)

Concatenate spatial domains `𝒟₁` and `𝒟₂` vertically, i.e.
concatenate the coordinates into a new point set containing
all points.
"""
Base.vcat(𝒟₁::AbstractDomain, 𝒟₂::AbstractDomain) =
  PointSet(hcat(coordinates(𝒟₁), coordinates(𝒟₂)))

"""
    vcat(𝒮₁, 𝒮₂)

Concatenate spatial data `𝒮₁` and `𝒮₂` vertically, i.e.
concatenate the underlying domains and additionally the
table of variables.
"""
function Base.vcat(𝒮₁::AbstractData, 𝒮₂::AbstractData)
  𝒯 = vcat(values(𝒮₁), values(𝒮₂), cols=:union)
  𝒟 = vcat(domain(𝒮₁), domain(𝒮₂))
  georef(𝒯, 𝒟)
end

"""
    hcat(𝒮₁, 𝒮₂)

Concatenate spatial data `𝒮₁` and `𝒮₂` horizontally, i.e.
concatenate the columns of the underlying table assuming
`nelms(𝒮₁) == nelms(𝒮₂)`.
"""
function Base.hcat(𝒮₁, 𝒮₂)
  @assert nelms(𝒮₁) == nelms(𝒮₂) "cannot join different number of points"
  𝒯 = hcat(values(𝒮₁), values(𝒮₂), makeunique=true)
  𝒟 = domain(𝒮₁)
  georef(𝒯, 𝒟)
end
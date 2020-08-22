# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    𝒪₁ ⊔ 𝒪₂

Disjoint union of spatial objects `𝒪₁` and `𝒪₂`.
"""
⊔(𝒪₁, 𝒪₂) = ⊔(geotrait(𝒪₁), geotrait(𝒪₂), 𝒪₁, 𝒪₂)

⊔(::GeoDomain, ::GeoDomain, 𝒟₁, 𝒟₂) =
  PointSet(hcat(coordinates(𝒟₁), coordinates(𝒟₂)))

function ⊔(::GeoData, ::GeoData, 𝒮₁, 𝒮₂)
  𝒯 = vcat(values(𝒮₁), values(𝒮₂), cols=:union)
  𝒟 = ⊔(domain(𝒮₁), domain(𝒮₂))
  georef(𝒯, 𝒟)
end
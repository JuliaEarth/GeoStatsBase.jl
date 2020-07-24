# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    𝒟₁ ⊔ 𝒟₂

Disjoint union of spatial domains `𝒟₁` and `𝒟₂`.
"""
⊔(𝒟₁::AbstractDomain, 𝒟₂::AbstractDomain) =
  PointSet(hcat(coordinates(𝒟₁), coordinates(𝒟₂)))

"""
    𝒮₁ ⊔ 𝒮₂

Disjoint union of spatial data `𝒮₁` and `𝒮₂`.
"""
function ⊔(𝒮₁::AbstractData, 𝒮₂::AbstractData)
  𝒯 = vcat(values(𝒮₁), values(𝒮₂), cols=:union)
  𝒟 = ⊔(domain(𝒮₁), domain(𝒮₂))
  georef(𝒯, 𝒟)
end

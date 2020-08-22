# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    VariableJoiner()

Join spatial data with shared domain to produce
spatial data with all variables included.
"""
struct VariableJoiner <: AbstractJoiner end

function join(sdata₁, sdata₂, joiner::VariableJoiner)
  @assert nelms(sdata₁) == nelms(sdata₂) "cannot join different number of points"

  𝒯 = hcat(values(sdata₁), values(sdata₂), makeunique=true)
  𝒟 = domain(sdata₁)

  georef(𝒯, 𝒟)
end

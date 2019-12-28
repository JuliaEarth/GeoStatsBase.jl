# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioWeighter(tdata, dre; variables=nothing)

Density ratio weights based on empirical distribution of
`variables` in target data `tdata`. Weights are estimated
with density ratio estimator `dre`.

### Notes

All estimators from DensityRatioEstimation.jl are supported.
"""
struct DensityRatioWeighter{DΩ<:AbstractData,
                            DRE<:DensityRatioEstimator} <: AbstractWeighter
  tdata::DΩ
  vars::Vector{Symbol}
  dre::DRE
end

function DensityRatioWeighter(tdata::DΩ, dre::DRE;
                              variables=nothing) where {DΩ<:AbstractData,
                                                        DRE<:DensityRatioEstimator}
  validvars = collect(keys(GeoStatsBase.variables(tdata)))
  wvars = variables ≠ nothing ? variables : validvars
  @assert wvars ⊆ validvars "invalid variables ($wvars) for spatial data"
  DensityRatioWeighter{DΩ,DRE}(tdata, wvars, dre)
end

function weight(sdata::AbstractData, weighter::DensityRatioWeighter)
  # retrieve method parameters
  tdata = weighter.tdata
  vars  = weighter.vars
  dre   = weighter.dre

  @assert vars ⊆ keys(variables(sdata)) "invalid variables ($vars) for spatial data"

  # numerator and denominator samples
  x_nu = view(tdata, vars)
  x_de = view(sdata, vars)

  # perform denstiy ratio estimation
  ratios = densratio(x_nu, x_de, dre)

  SpatialWeights(domain(sdata), ratios)
end

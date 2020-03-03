# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioWeighter(tdata; [options])

Density ratio weights based on empirical distribution of
variables in target data `tdata`.

## Optional parameters

* `variables` - Variables to consider (default to all)
* `estimator` - Density ratio estimator (default to `LSIF()`)
* `optlib`    - Optimization library (default to `default_optlib(estimator)`)

### Notes

Estimators from `DensityRatioEstimation.jl` are supported.
"""
struct DensityRatioWeighter{DΩ<:AbstractData} <: AbstractWeighter
  tdata::DΩ
  vars::Vector{Symbol}
  dre
  optlib
end

function DensityRatioWeighter(tdata::DΩ;
                              variables=nothing,
                              estimator=LSIF(),
                              optlib=default_optlib(estimator)) where {DΩ<:AbstractData}
  validvars = collect(keys(GeoStatsBase.variables(tdata)))
  wvars = variables ≠ nothing ? variables : validvars
  @assert wvars ⊆ validvars "invalid variables ($wvars) for spatial data"
  DensityRatioWeighter{DΩ}(tdata, wvars, estimator, optlib)
end

function weight(sdata::AbstractData, weighter::DensityRatioWeighter)
  # retrieve method parameters
  tdata  = weighter.tdata
  vars   = weighter.vars
  dre    = weighter.dre
  optlib = weighter.optlib

  @assert vars ⊆ keys(variables(sdata)) "invalid variables ($vars) for spatial data"

  # numerator and denominator samples
  Ω_nu = view(tdata, vars)
  Ω_de = view(sdata, vars)

  # TODO: eliminate this explicit conversion after
  # https://github.com/JuliaEarth/GeoStats.jl/projects/2 
  x_nu = collect(eachrow(Ω_nu[1:npoints(Ω_nu),vars]))
  x_de = collect(eachrow(Ω_de[1:npoints(Ω_de),vars]))

  # perform denstiy ratio estimation
  ratios = densratio(x_nu, x_de, dre, optlib=optlib)

  SpatialWeights(domain(sdata), ratios)
end

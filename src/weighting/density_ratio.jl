# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioWeighter(tdata, [vars]; [options])

Density ratio weights based on empirical distribution of
variables in target data `tdata`. Default to all variables.

## Optional parameters

* `estimator` - Density ratio estimator (default to `LSIF()`)
* `optlib`    - Optimization library (default to `default_optlib(estimator)`)

### Notes

Estimators from `DensityRatioEstimation.jl` are supported.
"""
struct DensityRatioWeighter <: AbstractWeighter
  tdata
  vars
  dre
  optlib
end

function DensityRatioWeighter(tdata, vars=nothing; estimator=LSIF(),
                              optlib=default_optlib(estimator))
  validvars = collect(name.(variables(tdata)))
  wvars = isnothing(vars) ? validvars : vars
  @assert wvars ⊆ validvars "invalid variables ($wvars) for spatial data"
  DensityRatioWeighter(tdata, wvars, estimator, optlib)
end

function weight(sdata, weighter::DensityRatioWeighter)
  # retrieve method parameters
  tdata  = weighter.tdata
  vars   = weighter.vars
  dre    = weighter.dre
  optlib = weighter.optlib

  @assert vars ⊆ name.(variables(sdata)) "invalid variables ($vars) for spatial data"

  # numerator and denominator samples
  Ωnu = view(tdata, vars)
  Ωde = view(sdata, vars)
  xnu = collect(Tables.rows(values(Ωnu)))
  xde = collect(Tables.rows(values(Ωde)))

  # perform denstiy ratio estimation
  ratios = densratio(xnu, xde, dre, optlib=optlib)

  SpatialWeights(domain(sdata), ratios)
end
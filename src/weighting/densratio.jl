# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DensityRatioWeighting(tdata, [vars]; [options])

Density ratio weights based on empirical distribution of
variables in target data `tdata`. Default to all variables.

## Optional parameters

* `estimator` - Density ratio estimator (default to `LSIF()`)
* `optlib`    - Optimization library (default to `default_optlib(estimator)`)

### Notes

Estimators from [DensityRatioEstimation.jl]
(https://github.com/JuliaEarth/DensityRatioEstimation.jl)
are supported.
"""
struct DensityRatioWeighting <: WeightingMethod
  tdata
  vars
  dre
  optlib
end

function DensityRatioWeighting(tdata, vars=nothing; estimator=LSIF(),
                               optlib=default_optlib(estimator))
  validvars = collect(name.(variables(tdata)))
  wvars = isnothing(vars) ? validvars : vars
  @assert wvars ⊆ validvars "invalid variables ($wvars) for spatial data"
  DensityRatioWeighting(tdata, wvars, estimator, optlib)
end

function weight(sdata, method::DensityRatioWeighting)
  # retrieve method parameters
  tdata  = method.tdata
  vars   = method.vars
  dre    = method.dre
  optlib = method.optlib

  @assert vars ⊆ name.(variables(sdata)) "invalid variables ($vars) for spatial data"

  # numerator and denominator samples
  Ωnu = view(tdata, vars)
  Ωde = view(sdata, vars)
  xnu = collect(Tables.rows(values(Ωnu)))
  xde = collect(Tables.rows(values(Ωde)))

  # perform denstiy ratio estimation
  ratios = densratio(xnu, xde, dre, optlib=optlib)

  GeoWeights(domain(sdata), ratios)
end

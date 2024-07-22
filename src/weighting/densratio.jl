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
(https://github.com/JuliaML/DensityRatioEstimation.jl)
are supported.
"""
struct DensityRatioWeighting{D,V,E,O} <: WeightingMethod
  tdata::D
  vars::V
  dre::E
  optlib::O
end

function DensityRatioWeighting(tdata, vars=nothing; estimator=LSIF(), optlib=default_optlib(estimator))
  tvars = Tables.schema(values(tdata)).names
  wvars = isnothing(vars) ? tvars : vars
  @assert wvars ⊆ tvars "variables ($wvars) not found in geospatial data"
  DensityRatioWeighting(tdata, wvars, estimator, optlib)
end

function weight(sdata, method::DensityRatioWeighting)
  # retrieve method parameters
  tdata = method.tdata
  vars = method.vars
  dre = method.dre
  optlib = method.optlib

  ttable = Tables.columns(values(tdata))
  stable = Tables.columns(values(sdata))

  svars = Tables.schema(stable).names
  @assert vars ⊆ svars "variables ($vars) not found in geospatial data"

  # numerator and denominator samples
  tcols = [var => Tables.getcolumn(ttable, var) for var in vars]
  scols = [var => Tables.getcolumn(stable, var) for var in vars]
  xnu = [collect(r) for r in Tables.rowtable((; tcols...))]
  xde = [collect(r) for r in Tables.rowtable((; scols...))]

  # perform denstiy ratio estimation
  ratios = densratio(xnu, xde, dre, optlib=optlib)

  GeoWeights(domain(sdata), ratios)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    mean(ensemble)

Mean of `ensemble`.
"""
function mean(ensemble::Ensemble)
  μs = (; (variable => mean(reals) for (variable, reals) in ensemble.reals)...)
  georef(μs, ensemble.domain)
end

"""
    var(ensemble)

Variance of `ensemble`.
"""
function var(ensemble::Ensemble)
  σs = (; (variable => var(reals) for (variable, reals) in ensemble.reals)...)
  georef(σs, ensemble.domain)
end

"""
    quantile(ensemble, p)

`p`-quantile of `ensemble`.
"""
function quantile(ensemble::Ensemble, p::Number)
  cols = []
  for (variable, reals) in ensemble.reals
    quantiles = map(1:nelements(ensemble.domain)) do location
      slice = getindex.(reals, location)
      quantile(slice, p)
    end
    push!(cols, variable => quantiles)
  end
  georef((; cols...), ensemble.domain)
end

quantile(ensemble::Ensemble, ps::AbstractVector) = [quantile(ensemble, p) for p in ps]

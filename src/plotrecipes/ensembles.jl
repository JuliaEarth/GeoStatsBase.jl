# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(ensemble::Ensemble, vars=nothing)
  # retrieve underlying domain
  sdomain = ensemble.domain

  # valid variables
  validvars = sort(collect(keys(ensemble.reals)))

  # plot all variables by default
  isnothing(vars) && (vars = validvars)
  @assert vars ⊆ validvars "invalid variable name"

  # number of realizations
  nreals = length(ensemble.reals[vars[1]])

  # plot at most 3 realizations per variable
  N = min(nreals, 3)
  layout --> (length(vars), N)
  legend --> false

  for (i, var) in enumerate(vars)
    reals = ensemble.reals[var][1:N]

    # find value limits across realizations
    minmax = extrema.(reals)
    vmin = minimum(first.(minmax))
    vmax = maximum(last.(minmax))

    for (j, real) in enumerate(reals)
      @series begin
        subplot := (i-1)*N + j
        title --> string(var, " $j")
        clims --> (vmin, vmax)
        sdomain, real
      end
    end
  end
end

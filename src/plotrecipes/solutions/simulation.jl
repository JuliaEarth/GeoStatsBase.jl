# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(solution::SimulationSolution, vars=nothing)
  # retrieve underlying domain
  sdomain = solution.domain

  # valid variables
  validvars = sort(collect(keys(solution.realizations)))

  # plot all variables by default
  isnothing(vars) && (vars = validvars)
  @assert vars ⊆ validvars "invalid variable name"

  # number of realizations
  nreals = length(solution.realizations[vars[1]])

  # plot at most 3 realizations per variable
  N = min(nreals, 3)
  layout --> (length(vars), N)
  legend --> false

  # select realizations at random
  inds = sample(1:nreals, N, replace=false)

  for (i, var) in enumerate(vars)
    reals = solution.realizations[var][inds]

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

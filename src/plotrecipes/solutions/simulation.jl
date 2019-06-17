# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(solution::SimulationSolution; variables=nothing)
  # retrieve underlying domain
  sdomain = domain(solution)

  # valid variables
  validvars = sort(collect(keys(solution.realizations)))

  # plot all variables by default
  variables == nothing && (variables = validvars)
  @assert variables ⊆ validvars "invalid variable name"

  # number of realizations
  nreals = length(solution.realizations[variables[1]])

  # plot at most 3 realizations per variable
  N = min(nreals, 3)
  layout --> (length(variables), N)
  legend --> false

  # select realizations at random
  inds = sample(1:nreals, N, replace=false)

  for (i, var) in enumerate(variables)
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

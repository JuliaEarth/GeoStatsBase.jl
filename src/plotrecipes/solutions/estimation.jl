# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(solution::EstimationSolution, vars=nothing)
  # retrieve underlying domain
  sdomain = solution.domain

  # valid variables
  validvars = sort(collect(keys(solution.mean)))

  # plot all variables by default
  isnothing(vars) && (vars = validvars)
  @assert vars ⊆ validvars "invalid variable name"

  # plot mean and variance for each variable
  layout --> (length(vars), 2)
  legend --> false

  for (i, var) in enumerate(vars)
    @series begin
      subplot := 2i - 1
      title --> string(var, " mean")
      sdomain, solution.mean[var]
    end
    @series begin
      subplot := 2i
      title --> string(var, " variance")
      sdomain, solution.variance[var]
    end
  end
end

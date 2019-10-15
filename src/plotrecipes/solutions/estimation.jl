# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(solution::EstimationSolution; variables=nothing)
  # retrieve underlying domain
  sdomain = domain(solution)

  # valid variables
  validvars = sort(collect(keys(solution.mean)))

  # plot all variables by default
  variables == nothing && (variables = validvars)
  @assert variables ⊆ validvars "invalid variable name"

  # plot mean and variance for each variable
  layout --> (length(variables), 2)
  legend --> false

  for (i, var) in enumerate(variables)
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

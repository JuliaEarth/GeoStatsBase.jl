# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(sdata::AbstractData, vars=nothing)
  # retrieve underlying domain
  sdomain = domain(sdata)

  # valid variables
  validvars = name.(variables(sdata))

  # plot all variables by default
  isnothing(vars) && (vars = validvars)
  @assert vars ⊆ validvars "invalid variable name"

  # shared plot specs
  layout --> length(vars)

  for (i, var) in enumerate(vars)
    # retrieve valid values
    vals = map(1:npoints(sdata)) do ind
      v = sdata[ind,var]
      ismissing(v) ? NaN : v
    end
    @series begin
      subplot := i
      title --> string(var)
      legend --> false
      sdomain, vals
    end
  end
end

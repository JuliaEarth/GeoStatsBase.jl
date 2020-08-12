# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(sdata::AbstractData; variables=nothing)
  # retrieve underlying domain
  sdomain = domain(sdata)

  # valid variables
  validvars = name.(GeoStatsBase.variables(sdata))

  # plot all variables by default
  isnothing(variables) && (variables = validvars)
  @assert variables ⊆ validvars "invalid variable name"

  # shared plot specs
  layout --> length(variables)

  for (i, var) in enumerate(variables)
    # retrieve valid values
    vals = map(1:npoints(sdata)) do ind
      if isvalid(sdata, ind, var)
        v = sdata[ind,var]
        v isa Number ? v : get(v)
      else
        NaN
      end
    end
    @series begin
      subplot := i
      title --> string(var)
      legend --> false
      sdomain, vals
    end
  end
end

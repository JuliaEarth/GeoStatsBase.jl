# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(spatialdata::AbstractSpatialData; variables=nothing)
  # retrieve underlying domain
  sdomain = domain(spatialdata)

  # valid variables
  vars = GeoStatsBase.variables(spatialdata)
  validvars = sort([var for (var, V) in vars if V <: Number])

  # plot all variables by default
  variables == nothing && (variables = validvars)
  @assert variables ⊆ validvars "invalid variable name"

  # shared plot specs
  layout --> length(variables)

  for (i, var) in enumerate(variables)
    # retrieve valid values
    vals = map(1:npoints(spatialdata)) do ind
      if isvalid(spatialdata, ind, var)
        value(spatialdata, ind, var)
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

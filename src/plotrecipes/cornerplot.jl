# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function cornerplot(sdata::AbstractData, vars=nothing;
                    quantiles=[0.25,0.50,0.75], cdf=false,
                    bandwidthx=100, bandwidthy=100)
  vars  = vars ≠ nothing ? vars : collect(keys(variables(sdata)))

  # variables in alphabetical order
  sort!(vars); n = length(vars)

  plts = []
  for i in 1:n, j in 1:n
    if i == j
      push!(plts, distplot1d(sdata, vars[i], quantiles=quantiles, cdf=cdf))
    elseif i < j
      push!(plts, distplot2d(sdata, vars[i], vars[j], quantiles=quantiles,
                             bandwidthx=bandwidthx, bandwidthy=bandwidthy))
    end
  end

  RecipesBase.plot(plts...)
end

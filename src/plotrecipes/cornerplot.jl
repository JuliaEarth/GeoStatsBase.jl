# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

function cornerplot(sdata::AbstractData, vars=nothing;
                    quantiles=[0.25,0.50,0.75],
                    bandwidthx=100, bandwidthy=100,
                    kwargs...)
  # variables in alphabetical order
  vars = vars ≠ nothing ? vars : sort(collect(name.(variables(sdata))))

  plts = []
  n = length(vars)
  for i in 1:n, j in 1:n
    xticks = i == n
    xguide = i == n ? vars[j] : ""
    yticks = i > 1 && j == 1
    yguide = i > 1 && j == 1 ? vars[i] : ""
    if i == j
      p = distplot1d(sdata, vars[i], quantiles=quantiles,
                     xticks=xticks, yticks=yticks,
                     xguide=xguide, yguide=yguide)
    elseif i > j
      p = distplot2d(sdata, vars[j], vars[i], quantiles=quantiles,
                     bandwidthx=bandwidthx, bandwidthy=bandwidthy,
                     xticks=xticks, yticks=yticks,
                     xguide=xguide, yguide=yguide)
    else
      p = RecipesBase.plot(framestyle=:none)
    end
    push!(plts, p)
  end

  RecipesBase.plot(plts...; layout=(n,n), kwargs...)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@userplot DistPlot1D

@recipe function f(dp::DistPlot1D; quantiles=[0.25,0.50,0.75])
  # retrieve inputs
  sdata = dp.args[1]
  var   = dp.args[2]

  # fit spatial statistics
  h = normalize(EmpiricalHistogram(sdata, var))
  q = quantile(sdata, var, quantiles)
  μ = mean(sdata, var)

  legend --> false
  framestyle --> :box
  grid --> false
  xguide --> var

  # plot histogram
  @series begin
    h
   end

  # plot quantiles
  @series begin
    seriestype --> :vline
    primary --> false
    seriescolor --> :black
    linestyle --> :dash
    q
  end

  # plot mean
  @series begin
    seriestype --> :vline
    primary --> false
    seriescolor --> :green
    [μ]
  end
end

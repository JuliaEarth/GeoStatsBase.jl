# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@userplot DistPlot1D

@recipe function f(dp::DistPlot1D; quantiles=[0.25,0.50,0.75])
  # retrieve inputs
  sdata = dp.args[1]
  var   = dp.args[2]

  # fit spatial statistics
  h = normalize(histogram(sdata, var))
  q = quantile(sdata, var, quantiles)
  μ = mean(sdata, var)

  legend --> false
  grid --> false
  frame --> :box
  xguide --> var

  # plot histogram
  @series begin
    seriestype --> :step
    color --> :black
    h
  end

  # plot quantiles
  @series begin
    seriestype --> :vline
    primary --> false
    color --> :black
    linestyle --> :dash
    q
  end

  # plot mean
  @series begin
    seriestype --> :vline
    primary --> false
    color --> :green
    [μ]
  end
end

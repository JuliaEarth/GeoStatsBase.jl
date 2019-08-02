# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@userplot DistPlot1D

@recipe function f(dp::DistPlot1D; quantiles=[0.25,0.50,0.75], cdf=false)
  # retrieve inputs
  sdata = dp.args[1]
  var   = dp.args[2]

  # fit spatial statistics
  h = normalize(histogram(sdata, var))
  q = quantile(sdata, var, quantiles)
  μ = mean(sdata, var)

  # plot coordinates
  x = midpoints(h.edges[1])
  y = h.weights
  s = x[2] - x[1]

  legend --> false
  grid --> false
  frame --> :box
  xguide --> var

  @series begin
    seriestype --> :step
    color --> :black
    if cdf
      ysum = cumsum(y)
      ycdf = ysum ./ ysum[end]
      xe = vcat(x[1]-s, x, x[end]+s)
      ye = vcat(0, ycdf, 1)
    else
      xe = vcat(x[1]-s, x, x[end]+s)
      ye = vcat(0, y, 0)
    end
    xe, ye
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

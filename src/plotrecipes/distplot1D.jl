# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@userplot DistPlot1D

@recipe function f(dp::DistPlot1D; quantiles=[0.25,0.50,0.75], cdf=false)
  # retrieve inputs
  sdata = dp.args[1]
  var   = dp.args[2]

  # fit spatial histogram and quantile
  h = normalize(histogram(sdata, var))
  q = quantile(sdata, var, quantiles)
  x = midpoints(h.edges[1])
  y = h.weights
  s = x[2] - x[1]

  legend --> false
  grid --> false
  color --> :black
  xguide --> var

  @series begin
    seriestype --> :step
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

  @series begin
    seriestype --> :vline
    primary --> false
    linestyle --> :dash
    q
  end
end

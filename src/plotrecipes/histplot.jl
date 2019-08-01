# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@userplot HistPlot

@recipe function f(hp::HistPlot; showcdf=false)
  # retrieve inputs
  sdata = hp.args[1]
  vars  = length(hp.args) == 2 ? hp.args[2] : keys(variables(sdata))

  layout --> length(vars)
  legend --> false
  color --> :black

  for (i, var) in enumerate(vars)
    h = normalize(histogram(sdata, var))
    q = quantile(sdata, var, [0.25,0.50,0.75])
    x = midpoints(h.edges[1])
    y = h.weights
    s = x[2] - x[1]

    @series begin
      subplot := i
      seriestype --> :step
      if showcdf
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
      subplot := i
      primary := false
      seriestype --> :vline
      linestyle --> :dash
      xguide --> var
      q
    end
  end
end

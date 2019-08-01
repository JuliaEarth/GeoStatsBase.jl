# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@userplot HistPlot

@recipe function f(hp::HistPlot; showcdf=true)
  # retrieve inputs
  sdata = hp.args[1]
  vars  = length(hp.args) == 2 ? hp.args[2] : keys(variables(sdata))

  layout --> length(vars)
  legend --> false

  for (i, var) in enumerate(vars)
    xguide --> var
    h = normalize(histogram(sdata, var))
    x = midpoints(h.edges[1])
    y = h.weights
    @series begin
      subplot := i
      seriestype --> :bar
      color --> :black
      x, y
    end
    if showcdf
      @series begin
        subplot := i
        seriestype --> :step
        color --> :red
        linewidth --> 2
        ysum = cumsum(y)
        ycdf = ysum ./ ysum[end]
        step = x[2] - x[1]
        xe = vcat(x[1]-step, x, x[end]+step)
        ye = vcat(0, ycdf, 1)
        xe, ye
      end
    end
  end
end

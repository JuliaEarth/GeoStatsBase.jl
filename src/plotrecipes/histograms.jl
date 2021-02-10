# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(hist::EmpiricalHistogram)
  # retrieve inputs
  sdata = hist.args[1]
  var   = hist.args[2]

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
    seriestype --> :step
    seriescolor --> :black
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

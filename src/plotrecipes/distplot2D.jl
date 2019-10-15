# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@userplot DistPlot2D

@recipe function f(dp::DistPlot2D; quantiles=[0.25,0.50,0.75],
                                   bandwidthx=100, bandwidthy=100)
  # retrieve inputs
  sdata = dp.args[1]
  var₁  = dp.args[2]
  var₂  = dp.args[3]

  x = vec(sdata[var₁])
  y = vec(sdata[var₂])

  # fit average shifted histogram
  h = ash(x, y, mx=bandwidthx, my=bandwidthy)
  hx, hy, hz = h.rngx, h.rngy, h.z
  ls = quantile(vec(hz), quantiles)

  # 2D mean vector
  μ = mean([x y], dims=1)

  # plot scatter of points
  @series begin
    seriestype --> :scatter
    primary --> false
    color --> :black
    alpha --> 0.5
    markersize --> 1
    x, y
  end

  # plot 2D mean
  @series begin
    seriestype --> :vline
    primary --> false
    color --> :green
    [μ[1]]
  end
  @series begin
    seriestype --> :hline
    primary --> false
    color --> :green
    [μ[2]]
  end
  @series begin
    seriestype --> :scatter
    primary --> false
    color --> :green
    marker --> :square
    markersize --> 4
    [μ[1]], [μ[2]]
  end

  seriestype --> :contour
  aspect_ratio --> :equal
  legend --> false
  grid --> false
  frame --> :box
  color --> :black
  levels --> ls
  xguide --> var₁
  yguide --> var₂

  hx, hy, hz
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@userplot DistPlot1D

@recipe function f(dp::DistPlot1D; quantiles=[0.25,0.50,0.75])
  # retrieve inputs
  sdata = dp.args[1]
  var   = dp.args[2]

  hist = EmpiricalHistogram(sdata, var)
  RecipesBase.plot(hist)
end

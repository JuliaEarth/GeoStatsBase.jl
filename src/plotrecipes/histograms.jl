# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(hist::EmpiricalHistogram)
  seriestype --> :step
  seriescolor --> :black
  legend --> false
  framestyle --> :box
  grid --> false

  normalize(hist.hist)
end

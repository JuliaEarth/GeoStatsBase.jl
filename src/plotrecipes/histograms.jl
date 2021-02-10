# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(hist::EmpiricalHistogram)
  seriestype --> :step
  seriescolor --> :black
  hist.hist
end

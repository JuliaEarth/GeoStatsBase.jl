# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(hist::EmpiricalHistogram)
  # fit spatial statistics
  h = normalize(EmpiricalHistogram(sdata, var))

  # plot histogram
  @series begin
    seriestype --> :step
    seriescolor --> :black
    h
  end
end

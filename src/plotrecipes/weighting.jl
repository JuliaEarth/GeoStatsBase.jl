# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(w::GeoWeights)
  @series begin
    label --> "weights"
    domain(w), collect(w)
  end
end

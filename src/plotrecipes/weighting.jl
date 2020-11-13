# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(w::SpatialWeights)
  @series begin
    label --> "weights"
    domain(w), collect(w)
  end
end

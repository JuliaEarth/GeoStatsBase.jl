# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(wd::WeightedSpatialData)
  @series begin
    label --> "weights"
    domain(wd), wd.weights
  end
end

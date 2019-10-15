# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(partition::SpatialPartition)
  marker --> :auto
  for object in partition
    @series begin
      object
    end
  end
end

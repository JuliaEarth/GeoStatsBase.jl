# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(partition::SpatialPartition)
  marker --> :auto
  for object in partition
    @series begin
      object
    end
  end
end

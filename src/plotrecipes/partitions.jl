# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(partition::SpatialPartition)
  marker --> :auto
  for p in partition
    @series begin
      p
    end
  end
end

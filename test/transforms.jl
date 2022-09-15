@testset "Transforms" begin
  d = georef((z=1:1000, w=rand(1000)))
  n = d |> Select(:z)
  t = n |> Tables.columns
  @test n isa GeoData
  @test Tables.columnnames(t) == (:z, :geometry)
  n = d |> (Select(:w) → Quantile())
  t = n |> Tables.columns
  @test n isa GeoData
  @test Tables.columnnames(t) == (:w, :geometry)
end
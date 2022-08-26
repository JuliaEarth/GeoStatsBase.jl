@testset "EmpiricalHistogram" begin
  sdata = georef((z=rand(100),))
  h = EmpiricalHistogram(sdata, :z; nbins=10)
  c, w = values(h)
  @test length(c) == 10
  @test length(w) == 10
end

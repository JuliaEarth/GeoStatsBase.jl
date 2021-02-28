@testset "EmpiricalHistogram" begin
  sdata = georef((z=rand(100),))
  h = EmpiricalHistogram(sdata, :z; nbins=10)
  c, w = values(h)
  @test length(c) == 10
  @test length(w) == 10

  Random.seed!(123)
  z₁ = randn(10000)
  z₂ = z₁ + randn(10000)
  d = georef((z₁=z₁,z₂=z₂), CartesianGrid(100,100))
  h1 = EmpiricalHistogram(d, :z₁)
  h2 = EmpiricalHistogram(d, :z₂)

  if visualtests
    @test_reference "data/histogram1.png" plot(h1)
    @test_reference "data/histogram2.png" plot(h2)
  end
end

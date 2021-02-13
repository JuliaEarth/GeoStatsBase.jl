@testset "EmpiricalHistogram" begin
  Random.seed!(123)
  z₁ = randn(10000)
  z₂ = z₁ + randn(10000)
  d = georef(DataFrame(z₁=z₁,z₂=z₂), RegularGrid(100,100))
  h1 = EmpiricalHistogram(d, :z₁)
  h2 = EmpiricalHistogram(d, :z₂)

  # kwargs
  sdata = georef((z=rand(100),))
  h = EmpiricalHistogram(sdata, :z; nbins=10)
  c, w = values(h)
  @test length(c) == 10
  @test length(w) == 10

  if visualtests
      @test_ref_plot "data/empiricalhistogram1.png" plot(h1)
      @test_ref_plot "data/empiricalhistogram2.png" plot(h2)
  end
end

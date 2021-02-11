@testset "EmpiricalHistogram" begin
  Random.seed!(123)
  z₁ = randn(10000)
  z₂ = z₁ + randn(10000)
  d = georef(DataFrame(z₁=z₁,z₂=z₂), RegularGrid(100,100))

  if visualtests
      @test_ref_plot "data/empiricalhistogram1.png" plot(EmpiricalHistogram(d, :z₁))
      @test_ref_plot "data/empiricalhistogram2.png" plot(EmpiricalHistogram(d, :z₂))
  end
end
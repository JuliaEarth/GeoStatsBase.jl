@testset "sampling" begin
  t = georef((z=rand(50, 50),))
  s = sample(t, UniformSampling(100))
  @test nrow(s) == 100
end

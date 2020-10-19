@testset "Sampling" begin
  @testset "UniformSampler" begin
    d = RegularGrid(100,100)
    s = sample(d, UniformSampler(100))
    μ = mean(coordinates(s), dims=2)
    @test nelms(s) == 100
    @test isapprox(μ, [50.,50.], atol=10.)
  end

  @testset "BallSampler" begin
    d = RegularGrid(100,100)
    s = sample(d, BallSampler(10.))
    n = nelms(s)
    X = coordinates(s, sample(1:n, 2, replace=false))
    x, y = X[:,1], X[:,2]
    @test n < 100
    @test sqrt(sum((x - y).^2)) ≥ 10.

    d = RegularGrid(100,100)
    s = sample(d, BallSampler(20.))
    n = nelms(s)
    X = coordinates(s, sample(1:n, 2, replace=false))
    x, y = X[:,1], X[:,2]
    @test n < 50
    @test sqrt(sum((x - y).^2)) ≥ 20.
  end

  @testset "WeightedSampler" begin
    # uniform weights => uniform sampler
    Random.seed!(2020)
    d = RegularGrid(100,100)
    s = sample(d, WeightedSampler(100))
    μ = mean(coordinates(s), dims=2)
    @test nelms(s) == 100
    @test isapprox(μ, [50.,50.], atol=10.)
  end
end

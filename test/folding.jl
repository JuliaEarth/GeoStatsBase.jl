@testset "Folding" begin
  @testset "Uniform" begin
    d = CartesianGrid(100, 100)
    f = folds(d, UniformFolding(10))
    for (source, target) in f
      @test length(source) == 9000
      @test length(target) == 1000
    end
    @test length(collect(f)) == 10
  end

  @testset "One" begin
    d = CartesianGrid(10, 10)
    f = folds(d, OneFolding())
    for (source, target) in f
      @test length(source) == 99
      @test length(target) == 1
    end
    @test length(collect(f)) == 100
  end

  @testset "Block" begin
    d = CartesianGrid(100, 100)
    f = folds(d, BlockFolding((10.0, 10.0)))
    for (source, target) in f
      @test length(source) ∈ [9100, 9400, 9600]
      @test length(target) == 100
    end
    @test length(collect(f)) == 100
  end

  @testset "Ball" begin
    d = CartesianGrid(50, 50)
    f = folds(d, BallFolding(MetricBall(10.0)))
    @test length(collect(f)) == 2500
    ps = collect(f)
    ms = length.(first.(ps))
    ns = length.(last.(ps))
    @test all(2183 .≤ ms .≤ 2410)
    @test all(ns .== 1)
  end
end

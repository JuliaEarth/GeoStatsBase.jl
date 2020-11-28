@testset "Folding" begin
  @testset "Random" begin
    d = RegularGrid(100,100)
    folds = RandomFolding(d, 10)
    @test length(folds) == 10
    for (train, test) in folds
      @test nelms(train) == 9000
      @test nelms(test) == 1000
    end
  end

  @testset "Block" begin
    d = RegularGrid(100,100)
    folds = BlockFolding(d, (10.,10.))
    @test length(folds) == 100
    for (train, test) in folds
      @test nelms(train) ∈ [9100,9400,9600]
      @test nelms(test) == 100
    end
  end

  @testset "Ball" begin
    d = RegularGrid(50,50)
    folds = BallFolding(d, BallNeighborhood(10.))
    @test length(folds) == 2500
    fs = collect(folds)
    ms = nelms.(first.(fs))
    ns = nelms.(last.(fs))
    @test all(2183 .≤ ms .≤ 2410)
    @test all(ns .== 1)
  end
end

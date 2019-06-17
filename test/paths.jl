@testset "Paths" begin
  grid = RegularGrid{Float64}(100,100)

  for path in [SimplePath(grid), RandomPath(grid)]
    @test length(path) == 100*100
  end

  @testset "SimplePath" begin
    path = SimplePath(grid)
    @test collect(path) == collect(1:100*100)
  end

  @testset "RandomPath" begin
    path = RandomPath(grid)
    @test all(1 .≤ collect(path) .≤ 100*100)
  end

  @testset "SourcePath" begin
    grid = RegularGrid{Float64}(3,3)
    pset = PointSet(coordinates(grid))

    for sdomain in [grid, pset]
      path = SourcePath(sdomain, [1,9])
      @test collect(path) == [1,9,2,4,6,8,5,3,7]

      path = SourcePath(sdomain, [1])
      @test collect(path) == [1,2,4,5,3,7,6,8,9]
    end
  end

  @testset "ShiftedPath" begin
    path = SimplePath(RegularGrid{Float64}(3,3))
    @test collect(ShiftedPath(path,  0)) == collect(1:9)
    @test collect(ShiftedPath(path,  1)) == vcat(collect(2:9), [1])
    @test collect(ShiftedPath(path, -1)) == vcat([9], collect(1:8))
    @test length(ShiftedPath(path,  0)) == 9
    @test length(ShiftedPath(path,  1)) == 9
    @test length(ShiftedPath(path, -1)) == 9
  end
end

@testset "initbuff" begin
  data1D = georef(CSV.File(joinpath(datadir, "data1D.tsv")), (:x,))
  data2D = georef(CSV.File(joinpath(datadir, "data2D.tsv")), (:x, :y))

  @testset "nearest" begin
    grid = CartesianGrid((100,), (-0.5,), (1.0,))
    buff, mask = initbuff(grid, (; value=Float64), NearestInit(), data=data1D)
    for (i, j) in (100 => 11, 81 => 9, 11 => 2, 21 => 3, 91 => 10, 51 => 6, 61 => 7, 71 => 8, 31 => 4, 41 => 5, 1 => 1)
      @test buff[:value][i] == data1D.value[j]
      @test mask[:value][i] == true
    end

    grid = CartesianGrid((100, 100), (-0.5, -0.5), (1.0, 1.0))
    buff, mask = initbuff(grid, (; value=Float64), NearestInit(), data=data2D)
    for (i, j) in (5076 => 3, 2526 => 1, 7551 => 2)
      @test buff[:value][i] == data2D.value[j]
      @test mask[:value][i] == true
    end

    pset = PointSet([(25, 25), (50, 75), (75, 50)])
    buff, mask = initbuff(pset, (; value=Float64), NearestInit(), data=data2D)
    for (i, j) in (2 => 2, 3 => 3, 1 => 1)
      @test buff[:value][i] == data2D.value[j]
      @test mask[:value][i] == true
    end
  end

  @testset "explicit" begin
    data = georef((z=rand(10),), rand(Point, 10))
    grid = CartesianGrid(10, 10, 10)

    # copy data to first locations in domain
    buff, mask = initbuff(grid, (; z=Float64), ExplicitInit(), data=data)
    for (i, j) in (i => i for i in 1:10)
      @test buff[:z][i] == data.z[j]
      @test mask[:z][i] == true
    end

    # copy data to last locations in domain
    buff, mask = initbuff(grid, (; z=Float64), ExplicitInit(991:1000), data=data)
    for (i, j) in (j => i for (i, j) in enumerate(991:1000))
      @test buff[:z][i] == data.z[j]
      @test mask[:z][i] == true
    end

    # copy first 3 data points to last 3 domain locations
    buff, mask = initbuff(grid, (; z=Float64), ExplicitInit(1:3, 998:1000), data=data)
    for (i, j) in (j => i for (i, j) in enumerate(998:1000))
      @test buff[:z][i] == data.z[j]
      @test mask[:z][i] == true
    end
  end
end

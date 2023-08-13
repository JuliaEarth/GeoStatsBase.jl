@testset "initbuff" begin
  data1D = georef(CSV.File(joinpath(datadir, "data1D.tsv")), (:x,))
  data2D = georef(CSV.File(joinpath(datadir, "data2D.tsv")), (:x, :y))

  @testset "nearest" begin
    grid1D = CartesianGrid((100,), (-0.5,), (1.0,))
    buff = initbuff(data1D, grid1D, NearestInit())
    for (i, j) in (100 => 11, 81 => 9, 11 => 2, 21 => 3, 91 => 10, 51 => 6, 61 => 7, 71 => 8, 31 => 4, 41 => 5, 1 => 1)
      @test buff[:value][i] == data1D.value[j]
    end

    grid2D = CartesianGrid((100, 100), (-0.5, -0.5), (1.0, 1.0))
    buff = initbuff(data2D, grid2D, NearestInit())
    for (i, j) in (5076 => 3, 2526 => 1, 7551 => 2)
      @test buff[:value][i] == data2D.value[j]
    end

    ps2D = PointSet([25.0 50.0 75.0; 25.0 75.0 50.0])
    buff = initbuff(data2D, ps2D, NearestInit())
    for (i, j) in (2 => 2, 3 => 3, 1 => 1)
      @test buff[:value][i] == data2D.value[j]
    end
  end

  @testset "explicit" begin
    d = georef((z=rand(10),), rand(2, 10))
    g = CartesianGrid(10, 10)

    # copy data to first locations in domain
    buff = initbuff(d, g, ExplicitInit())
    for (i, j) in (i => i for i in 1:10)
      @test buff[:z][i] == d.z[j]
    end

    # copy data to last locations in domain
    buff = initbuff(d, g, ExplicitInit(91:100))
    for (i, j) in (j => i for (i, j) in enumerate(91:100))
      @test buff[:z][i] == d.z[j]
    end

    # copy first 3 data points to last 3 domain locations
    buff = initbuff(d, g, ExplicitInit(1:3, 98:100))
    for (i, j) in (j => i for (i, j) in enumerate(98:100))
      @test buff[:z][i] == d.z[j]
    end
  end
end

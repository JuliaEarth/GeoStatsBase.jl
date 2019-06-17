@testset "Neighborhoods" begin
  @testset "BallNeighborhood" begin
    # Euclidean metric
    grid1D = RegularGrid{Float64}(100)
    neigh = BallNeighborhood(grid1D, .5)
    @test neigh(1) == [1]

    grid2D = RegularGrid{Float64}(100,100)
    neigh = BallNeighborhood(grid2D, 1.)
    @test neigh(1) == [1,2,101]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,101])
    neigh = BallNeighborhood(grid2D, .5)
    @test neigh(1) == [1]

    grid3D = RegularGrid{Float64}(100,100,100)
    neigh = BallNeighborhood(grid3D, .5)
    @test neigh(1) == [1]

    grid4D = RegularGrid{Float64}(10,20,30,40)
    neigh = BallNeighborhood(grid4D, .5)
    @test neigh(1) == [1]

    ps2D = PointSet([0. 1. 0. 1.; 0. 0. 1. 1.])
    neigh = BallNeighborhood(ps2D, 1.)
    @test neigh(1) == [1,2,3]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,3])

    # Chebyshev metric
    grid1D = RegularGrid{Float64}(100)
    neigh = BallNeighborhood(grid1D, .5, Chebyshev())
    @test neigh(1) == [1]

    grid2D = RegularGrid{Float64}(100,100)
    neigh = BallNeighborhood(grid2D, 1., Chebyshev())
    @test neigh(1) == [1,2,101,102]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,101,102])
    neigh = BallNeighborhood(grid2D, 2., Chebyshev())
    @test neigh(1) == [1,2,3,101,102,103,201,202,203]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,3,101,102,103,201,202,203])

    grid3D = RegularGrid{Float64}(100,100,100)
    neigh = BallNeighborhood(grid3D, .5, Chebyshev())
    @test neigh(1) == [1]

    grid4D = RegularGrid{Float64}(10,20,30,40)
    neigh = BallNeighborhood(grid4D, .5, Chebyshev())
    @test neigh(1) == [1]

    ps2D = PointSet([0. 1. 0. 1.; 0. 0. 1. 1.])
    neigh = BallNeighborhood(ps2D, 1., Chebyshev())
    @test neigh(1) == [1,2,3,4]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,3,4])
  end

  @testset "CylinderNeighborhood" begin
    grid3D = RegularGrid{Float64}(3,3,3)

    neigh = CylinderNeighborhood(grid3D, 1., 1.)
    @test neigh(1) == [1,2,4,10,11,13]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,4,10,11,13])

    neigh = CylinderNeighborhood(grid3D, 2., 1.)
    @test neigh(1) == [1,2,3,4,5,7,10,11,12,13,14,16]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,3,4,5,7,10,11,12,13,14,16])

    neigh = CylinderNeighborhood(grid3D, 1., 2.)
    @test neigh(1) == [1,2,4,10,11,13,19,20,22]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,4,10,11,13,19,20,22])

    grid3D = RegularGrid{Float64}(100,100,100)

    neigh = CylinderNeighborhood(grid3D, 1., 1.)
    @test neigh(1) == [1,2,101,10001,10002,10101]
    @test all(isneighbor(neigh, 1, i) for i in [1,2,101,10001,10002,10101])
  end
end

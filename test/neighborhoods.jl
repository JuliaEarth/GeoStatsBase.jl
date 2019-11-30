@testset "Neighborhoods" begin
  @testset "BallNeighborhood" begin
    # Euclidean metric
    n = BallNeighborhood{1}(0.5)
    @test isneighbor(n, [0.], [0.])
    @test !isneighbor(n, [0.], [1.])

    n = BallNeighborhood{2}(1.0)
    @test isneighbor(n, [0.,0.], [0.,0.])
    @test isneighbor(n, [0.,0.], [1.,0.])
    @test isneighbor(n, [0.,0.], [0.,1.])

    # Chebyshev metric
    n = BallNeighborhood{1}(0.5, Chebyshev())
    @test isneighbor(n, [0.], [0.])
    @test !isneighbor(n, [0.], [1.])

    for r in [1.,2.,3.,4.,5.]
      n = BallNeighborhood{2}(r, Chebyshev())
      for i in 0.0:1.0:r, j in 0.0:1.0:r
        @test isneighbor(n, [0.,0.], [i,j])
      end
    end

    n = BallNeighborhood{2}(1.0)
    @test sprint(show, n) == "2D BallNeighborhood(1.0, Euclidean(0.0))"
    @test sprint(show, MIME"text/plain"(), n) == "2D BallNeighborhood\n  radius: 1.0\n  metric: Euclidean(0.0)"
  end

  @testset "CylinderNeighborhood" begin
    g = RegularGrid{Float64}(3,3,3)
    n = CylinderNeighborhood{3}(1., 1.)
    for i in [1,2,4,10,11,13]
      @test isneighbor(n, coordinates(g, 1), coordinates(g, i))
    end
    n = CylinderNeighborhood{3}(2., 1.)
    for i in [1,2,3,4,5,7,10,11,12,13,14,16]
      @test isneighbor(n, coordinates(g, 1), coordinates(g, i))
    end
    n = CylinderNeighborhood{3}(1., 2.)
    for i in [1,2,4,10,11,13,19,20,22]
      @test isneighbor(n, coordinates(g, 1), coordinates(g, i))
    end

    g = RegularGrid{Float64}(100,100,100)
    n = CylinderNeighborhood{3}(1., 1.)
    for i in [1,2,101,10001,10002,10101]
      @test isneighbor(n, coordinates(g, 1), coordinates(g, i))
    end

    n = CylinderNeighborhood{3}(1., 1.)
    @test sprint(show, n) == "3D CylinderNeighborhood(1.0, 1.0)"
    @test sprint(show, MIME"text/plain"(), n) == "3D CylinderNeighborhood\n  radius: 1.0\n  height: 1.0"
  end
end

@testset "Neighborhoods" begin
  @testset "BallNeighborhood" begin
    # Euclidean metric
    n = BallNeighborhood(0.5)
    @test isneighbor(n, [0.], [0.])
    @test !isneighbor(n, [0.], [1.])

    n = BallNeighborhood(1.0)
    @test isneighbor(n, [0.,0.], [0.,0.])
    @test isneighbor(n, [0.,0.], [1.,0.])
    @test isneighbor(n, [0.,0.], [0.,1.])

    # Chebyshev metric
    n = BallNeighborhood(0.5, Chebyshev())
    @test isneighbor(n, [0.], [0.])
    @test !isneighbor(n, [0.], [1.])

    for r in [1.,2.,3.,4.,5.]
      n = BallNeighborhood(r, Chebyshev())
      for i in 0.0:1.0:r, j in 0.0:1.0:r
        @test isneighbor(n, [0.,0.], [i,j])
      end
    end

    n = BallNeighborhood(1.0)
    @test sprint(show, n) == "BallNeighborhood(1.0, Euclidean(0.0))"
    @test sprint(show, MIME"text/plain"(), n) == "BallNeighborhood\n  radius: 1.0\n  metric: Euclidean(0.0)"
  end
end

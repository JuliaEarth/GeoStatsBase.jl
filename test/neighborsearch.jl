@testset "Neighborsearch" begin
  @testset "KBallSearcher" begin
    #create a regular grid to test
    domain = RegularGrid(10,10)

    #test 1: all points should be found
    k = 10
    ball = BallNeighborhood(100.0)
    searcher = KBallSearcher(domain, k, ball)

    xₒ = [5.0,5.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 10

    #test 2: radius of 1.0 m 5 points should be found
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearcher(domain, k, ball)

    xₒ = [5.0,5.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)
    @test length(neighbors) == 5
    @test neighbors[1] == 56

    #testing with masks
    mask = trues(nelms(domain))
    mask[56] = false #excluding location #56
    neighbors = GeoStatsBase.search(xₒ, searcher, mask=mask)
    @test length(neighbors) == 4

    #test 3: radius of 1.0 m but far just to find 1 point
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearcher(domain, k, ball)

    xₒ = [-0.2,-0.2]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 1

    #test 4: radius of 1.0 m but far just to find no points
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearcher(domain, k, ball)

    xₒ = [-10.0,-10.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 0
  end
end

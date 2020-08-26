@testset "Neighborsearch" begin
  @testset "NeighborhoodSearcher" begin
    𝒟 = RegularGrid(10,10)

    S = NeighborhoodSearcher(𝒟, BallNeighborhood(1.0))
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([1,2,11])
    n = GeoStatsBase.search([9.,0.], S)
    @test Set(n) == Set([9,10,20])
    n = GeoStatsBase.search([0.,9.], S)
    @test Set(n) == Set([91,81,92])
    n = GeoStatsBase.search([9.,9.], S)
    @test Set(n) == Set([100,99,90])

    S = NeighborhoodSearcher(𝒟, BallNeighborhood(√2))
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([1,2,11,12])
    n = GeoStatsBase.search([9.,0.], S)
    @test Set(n) == Set([9,10,19,20])
    n = GeoStatsBase.search([0.,9.], S)
    @test Set(n) == Set([81,82,91,92])
    n = GeoStatsBase.search([9.,9.], S)
    @test Set(n) == Set([89,90,99,100])
  end

  @testset "KNearestSearcher" begin
    𝒟 = RegularGrid(10,10)
    S = KNearestSearcher(𝒟, 3)
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([1,2,11])
    n = GeoStatsBase.search([9.,0.], S)
    @test Set(n) == Set([9,10,20])
    n = GeoStatsBase.search([0.,9.], S)
    @test Set(n) == Set([91,81,92])
    n = GeoStatsBase.search([9.,9.], S)
    @test Set(n) == Set([100,99,90])
  end

  @testset "KBallSearcher" begin
    #create a regular grid to test
    𝒟 = RegularGrid(10,10)

    #test 1: all points should be found
    k = 10
    ball = BallNeighborhood(100.0)
    searcher = KBallSearcher(𝒟, k, ball)

    xₒ = [5.0,5.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 10

    #test 2: radius of 1.0 m 5 points should be found
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearcher(𝒟, k, ball)

    xₒ = [5.0,5.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)
    @test length(neighbors) == 5
    @test neighbors[1] == 56

    #testing with masks
    mask = trues(nelms(𝒟))
    mask[56] = false #excluding location #56
    neighbors = GeoStatsBase.search(xₒ, searcher, mask=mask)
    @test length(neighbors) == 4

    #test 3: radius of 1.0 m but far just to find 1 point
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearcher(𝒟, k, ball)

    xₒ = [-0.2,-0.2]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 1

    #test 4: radius of 1.0 m but far just to find no points
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearcher(𝒟, k, ball)

    xₒ = [-10.0,-10.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 0
  end

  @testset "BoundedSearcher" begin
    𝒟 = RegularGrid(10,10)
    S1 = NeighborhoodSearcher(𝒟, BallNeighborhood(5.0))
    S2 = KNearestSearcher(𝒟, 10)
    B1 = BoundedSearcher(S1, 5)
    B2 = BoundedSearcher(S2, 5)
    n = GeoStatsBase.search(coordinates(𝒟, rand(1:100)), B1)
    @test length(n) == 5
    n = GeoStatsBase.search(coordinates(𝒟, rand(1:100)), B2)
    @test length(n) == 5
  end
end

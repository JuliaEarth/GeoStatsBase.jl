@testset "Neighborsearch" begin
  @testset "KBallSearcher" begin
    # KBallSearcher

    #create a regular grid to test
    pdomain = RegularGrid(10,10)

    #test 1: all points should be found
    k = 10
    ball = BallNeighborhood(100.0)
    kballsearcher = KBallSearcher(pdomain, k, ball)

    neighbors = neighbors = Vector{Int}(undef, k)
    xₒ = [5.0,5.0]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 10

    #test 2: radius of 1.0 m 5 points should be found
    k = 10
    ball = BallNeighborhood(1.0)
    kballsearcher = KBallSearcher(pdomain, k, ball)

    neighbors = Vector{Int}(undef, k)
    xₒ = [5.0,5.0]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)
    @test nneigh == 5
    @test neighbors[1] == 56

    #testing with masks
    mask = trues(npoints(pdomain))
    mask[56] = false #excluding location #56
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=mask)
    @test nneigh == 4

    #test 3: radius of 1.0 m but far just to find 1 point
    k = 10
    ball = BallNeighborhood(1.0)
    kballsearcher = KBallSearcher(pdomain, k, ball)

    neighbors = neighbors = Vector{Int}(undef, k)
    xₒ = [-0.2,-0.2]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 1

    #test 4: radius of 1.0 m but far just to find no points
    k = 10
    ball = BallNeighborhood(1.0)
    kballsearcher = KBallSearcher(pdomain, k, ball)

    neighbors = neighbors = Vector{Int}(undef, k)
    xₒ = [-10.0,-10.0]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 0
    
  end
end

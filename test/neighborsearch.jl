@testset "Neighborsearch" begin
  @testset "KBallSearcher" begin
    # KBallSearcher

    #create a regular grid to test
    pdomain = RegularGrid(10,10)

    #test 1: all points should be found
    maxneighbors = 10
    neigh = BallNeighborhood(100.0)
    searcher  = NeighborhoodSearcher(pdomain, neigh)
    kballsearcher = KBallSearcher(searcher,maxneighbors)

    neighbors = neighbors = Vector{Int}(undef, maxneighbors)
    xₒ = [5.0,5.0]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 10

    #test 2: radius of 1.0 m 5 points should be found
    maxneighbors = 10
    neigh = BallNeighborhood(1.0)
    searcher  = NeighborhoodSearcher(pdomain, neigh)
    kballsearcher = KBallSearcher(searcher,maxneighbors)

    neighbors = neighbors = Vector{Int}(undef, maxneighbors)
    xₒ = [5.0,5.0]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 5

    #test 3: radius of 1.0 m but far just to find 1 point
    maxneighbors = 10
    neigh = BallNeighborhood(1.0)
    searcher  = NeighborhoodSearcher(pdomain, neigh)
    kballsearcher = KBallSearcher(searcher,maxneighbors)

    neighbors = neighbors = Vector{Int}(undef, maxneighbors)
    xₒ = [-0.2,-0.2]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 1

    #test 4: radius of 1.0 m but far just to find no points
    maxneighbors = 10
    neigh = BallNeighborhood(1.0)
    searcher  = NeighborhoodSearcher(pdomain, neigh)
    kballsearcher = KBallSearcher(searcher,maxneighbors)

    neighbors = neighbors = Vector{Int}(undef, maxneighbors)
    xₒ = [-10.0,-10.0]
    nneigh = search!(neighbors,xₒ,kballsearcher; mask=nothing)

    @test nneigh == 0
    
  end
end

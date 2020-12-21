@testset "Neighborsearch" begin
  @testset "NeighborhoodSearch" begin
    𝒟 = RegularGrid(10,10)

    S = NeighborhoodSearch(𝒟, BallNeighborhood(1.0))
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([1,2,11])
    n = GeoStatsBase.search([9.,0.], S)
    @test Set(n) == Set([9,10,20])
    n = GeoStatsBase.search([0.,9.], S)
    @test Set(n) == Set([91,81,92])
    n = GeoStatsBase.search([9.,9.], S)
    @test Set(n) == Set([100,99,90])

    S = NeighborhoodSearch(𝒟, BallNeighborhood(√2))
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([1,2,11,12])
    n = GeoStatsBase.search([9.,0.], S)
    @test Set(n) == Set([9,10,19,20])
    n = GeoStatsBase.search([0.,9.], S)
    @test Set(n) == Set([81,82,91,92])
    n = GeoStatsBase.search([9.,9.], S)
    @test Set(n) == Set([89,90,99,100])

# Non-MinkowskiMetric example
    𝒟 = RegularGrid((360, 180), (0., -90.), (1., 1.))
    S = NeighborhoodSearch(𝒟, BallNeighborhood(150., Haversine(6371.0)))
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([32041, 32402, 32401, 32761, 32760])
  end

  @testset "KNearestSearch" begin
    𝒟 = RegularGrid(10,10)
    S = KNearestSearch(𝒟, 3)
    n = GeoStatsBase.search([0.,0.], S)
    @test Set(n) == Set([1,2,11])
    n = GeoStatsBase.search([9.,0.], S)
    @test Set(n) == Set([9,10,20])
    n = GeoStatsBase.search([0.,9.], S)
    @test Set(n) == Set([91,81,92])
    n = GeoStatsBase.search([9.,9.], S)
    @test Set(n) == Set([100,99,90])
  end

  @testset "KBallSearch" begin
    #create a regular grid to test
    𝒟 = RegularGrid(10,10)

    #test 1: all points should be found
    k = 10
    ball = BallNeighborhood(100.0)
    searcher = KBallSearch(𝒟, k, ball)

    xₒ = [5.0,5.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 10

    #test 2: radius of 1.0 m 5 points should be found
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearch(𝒟, k, ball)

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
    searcher = KBallSearch(𝒟, k, ball)

    xₒ = [-0.2,-0.2]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 1

    #test 4: radius of 1.0 m but far just to find no points
    k = 10
    ball = BallNeighborhood(1.0)
    searcher = KBallSearch(𝒟, k, ball)

    xₒ = [-10.0,-10.0]
    neighbors = GeoStatsBase.search(xₒ, searcher)

    @test length(neighbors) == 0
  end

  @testset "BoundedSearch" begin
    # maxneighbors tests
    𝒟 = RegularGrid(10,10)
    S1 = NeighborhoodSearch(𝒟, BallNeighborhood(5.0))
    S2 = KNearestSearch(𝒟, 10)
    B1 = BoundedSearch(S1, 5)
    B2 = BoundedSearch(S2, 5)
    n = GeoStatsBase.search(coordinates(𝒟, rand(1:100)), B1)
    @test length(n) == 5
    n = GeoStatsBase.search(coordinates(𝒟, rand(1:100)), B2)
    @test length(n) == 5

    # maxperoctant and maxpercategory tests
    maxk    = [0, 5, 10]
    maxoct  = [0, 2,  3]
    maxcat  = [Dict(), Dict(:K1=>2), Dict(:K1=>2, :K2=>2)]
    iprod   = Iterators.product

		# test routine for 2-D and 3-D
		function boundedtests(args, kwargs)
			for arg in args
				obj = object(arg[1])
				dim = ncoords(obj)
				for kwarg in kwargs
					b    = BoundedSearch(arg...; kwarg...)
					inds = GeoStatsBase.search(fill(5.0, dim), b)

					@test length(inds) <= b.maxneighbors || b.maxneighbors == 0
					@test length(inds) <= b.maxperoctant * 2^dim || b.maxperoctant == 0
					for (col,v) in b.maxpercategory
						nvals = view(values(obj), inds, col)
						@test sum(nvals .== 1) <= v
						@test sum(nvals .== 2) <= v
					end

					if arg[1] isa KNearestSearch
						catmax = length(b.maxpercategory) == 0 ? 0 : 4
						nmax   = maxneighbors(arg[1])

						k = [nmax, b.maxneighbors, b.maxperoctant * 2^dim, catmax]
						@test length(inds) == minimum(k[k .> 0])
					end
				end
			end
		end

		# 2-D case
		dims = (10, 10)
		𝒟 = georef((K1=rand(1:2, dims), K2=rand(1:2, dims)))
		S1 = NeighborhoodSearch(𝒟, BallNeighborhood(10.0))
		S2 = KNearestSearch(𝒟, 25)

		args = iprod([S1, S2], maxk)
		kwargs = [(maxperoctant=x[1], maxpercategory=x[2]) for x in iprod(maxoct, maxcat)]
		boundedtests(args, kwargs)

		# 3-D case
		dims = (10, 10, 10)
		𝒟 = georef((K1=rand(1:2, dims), K2=rand(1:2, dims)))
		S1 = NeighborhoodSearch(𝒟, EllipsoidNeighborhood([10. ,8. ,5.],[45, 45, 0]))
		S2 = KNearestSearch(𝒟, 64)

		args   = iprod([S1, S2], maxk)
		kwargs = [(maxperoctant=x[1], maxpercategory=x[2]) for x in iprod(maxoct, maxcat)]
		boundedtests(args, kwargs)
  end
end

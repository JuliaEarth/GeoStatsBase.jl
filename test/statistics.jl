@testset "Statistics" begin
  @testset "Solution" begin
    grid2D = RegularGrid{Float64}(3,3)
    realizations = Dict(:value => [i*ones(npoints(grid2D)) for i in 1:3])
    solution2D = SimulationSolution(grid2D, realizations)

    # mean
    mean2D = mean(solution2D)
    @test mean2D[1,:value] == 2.
    @test domain(mean2D) == solution2D.domain

    # variance
    variance2D = var(solution2D)
    @test variance2D[1,:value] == 1.
    @test domain(variance2D) == solution2D.domain

    # quantile (scalar)
    p = 0.5
    quantile2D = quantile(solution2D, p)
    @test quantile2D[1,:value] == 2.
    @test domain(quantile2D) == solution2D.domain

    # quantile (vector)
    ps = [0.0, 0.5, 1.0]
    quantiles2D = quantile(solution2D, ps)
    @test eltype(quantiles2D) <: SpatialStatistic

    # show methods
    @test sprint(show, mean2D) == "2D SpatialStatistic"
    @test sprint(show, MIME"text/plain"(), mean2D) == "2D SpatialStatistic\n  domain: 3×3 RegularGrid{Float64,2}\n  variables: value"
  end

  @testset "Data" begin
    # load data with bias towards large values (gold mine)
    sdata = readgeotable(joinpath(datadir,"clustered.csv"), coordnames=[:x,:y])

    # spatial mean
    μn = mean(sdata[:Au])
    μs = mean(sdata, :Au)
    @test abs(μn - 0.5) > abs(μs - 0.5)
    @test mean(sdata)[:Au] ≈ μs

    # spatial variance
    σn = var(sdata[:Au])
    σs = var(sdata, :Au)
    @test σn ≤ σs
    @test var(sdata)[:Au] ≈ σs

    # spatial quantile
    qn = quantile(sdata[:Au], 0.5)
    qs = quantile(sdata, :Au, 0.5)
    @test qn ≥ qs
    @test quantile(sdata, 0.5)[:Au] ≈ qs
  end
end

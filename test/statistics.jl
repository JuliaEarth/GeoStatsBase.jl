@testset "Statistics" begin
  @testset "Mode estimator" begin
    rng = Xoshiro(2023)
    d = LogNormal(0, 1)
    x = rand(rng, d, 1000)
    @test GeoStatsBase.hsm_mode([1, 2, 2, 3]) == 2.0
    @test GeoStatsBase.hsm_mode([1, 2, 2, 3, 5]) == 2.0
    @test GeoStatsBase.hsm_mode(x) < mean(x)
    @test GeoStatsBase.hsm_mode(x) < median(x)
    d = MixtureModel([Normal(), Normal(3, 0.2)], [0.7, 0.3])
    x = rand(rng, d, 1000)
    @test GeoStatsBase.hsm_mode(x) < mean(x)
    @test GeoStatsBase.hsm_mode(x) < median(x)
  end

  @testset "Declustering" begin
    # load data with bias towards large values (gold mine)
    gtb = georef(CSV.File(joinpath(datadir, "clustered.csv")), ("x", "y"))

    # declustered mean
    μs = mean(gtb.Au)
    μd = mean(gtb, "Au")
    @test μd < μs

    # declustered variance
    σs = var(gtb.Au)
    σd = var(gtb, "Au")
    @test σd < σs

    # declustered quantile
    qs = quantile(gtb.Au, 0.5)
    qd = quantile(gtb, "Au", 0.5)
    @test qd < qs

    # declustered histogram
    hs = histogram(gtb, "Au", UniformWeighting(), nbins=10)
    hd = histogram(gtb, "Au", nbins=10)
    @test last(hd.weights) < last(hs.weights)
  end
end

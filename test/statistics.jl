@testset "Statistics" begin
  rng = MersenneTwister(2023)

  # half sample mode
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

  # load data with bias towards large values (gold mine)
  sdata = georef(CSV.File(joinpath(datadir, "clustered.csv")), (:x, :y))

  # spatial mean
  μn = mean(sdata.Au)
  μs = mean(sdata, :Au)
  @test μs == mean(sdata, "Au")
  @test abs(μn - 0.5) > abs(μs - 0.5)

  # spatial variance
  σn = var(sdata.Au)
  σs = var(sdata, :Au)
  @test σs == var(sdata, "Au")
  @test isapprox(σn, σs, atol=1e-2)

  # spatial quantile
  qn = quantile(sdata.Au, 0.5)
  qs = quantile(sdata, :Au, 0.5)
  @test qs == quantile(sdata, "Au", 0.5)
  @test qn ≥ qs
end

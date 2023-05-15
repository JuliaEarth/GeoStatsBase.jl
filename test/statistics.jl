@testset "Statistics" begin
  # half sample mode
  d = LogNormal(0, 1)
  rs = rand(d, 1000)
  @test GeoStatsBase.hsm_mode([1, 2, 2, 3]) == 2.0
  @test GeoStatsBase.hsm_mode([1, 2, 2, 3, 5]) == 2.0
  @test GeoStatsBase.hsm_mode(rs) < mean(rs)
  @test GeoStatsBase.hsm_mode(rs) < median(rs)
  d = MixtureModel([Normal(), Normal(3, 0.2)], [0.7, 0.3])
  rs = rand(d, 1000)
  @test GeoStatsBase.hsm_mode(rs) < mean(rs)
  @test GeoStatsBase.hsm_mode(rs) < median(rs)

  # load data with bias towards large values (gold mine)
  sdata = georef(CSV.File(joinpath(datadir, "clustered.csv")), (:x, :y))

  # spatial mean
  μn = mean(sdata.Au)
  μs = mean(sdata, :Au)
  @test abs(μn - 0.5) > abs(μs - 0.5)
  @test mean(sdata)[:Au] ≈ μs

  # spatial variance
  σn = var(sdata.Au)
  σs = var(sdata, :Au)
  @test isapprox(σn, σs, atol=1e-2)
  @test var(sdata)[:Au] ≈ σs

  # spatial quantile
  qn = quantile(sdata.Au, 0.5)
  qs = quantile(sdata, :Au, 0.5)
  @test qn ≥ qs
  @test quantile(sdata, 0.5)[:Au] ≈ qs
end

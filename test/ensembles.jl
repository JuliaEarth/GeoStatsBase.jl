@testset "Ensembles" begin
  d = PointSet(rand(2, 100))
  r = (z=[1:100 for i in 1:10],)
  s = Ensemble(d, r)
  @test domain(s) == d
  @test s[:z] == r[:z]
  for i in 1:10
    @test s[i] == georef((z=1:100,), d)
  end

  s1 = Ensemble(d, r)
  s2 = Ensemble(d, r)
  @test s1 == s2

  @test sprint(show, s) == "2D Ensemble"
  @test sprint(show, MIME"text/plain"(), s) ==
        "2D Ensemble\n  domain:    100 PointSet{2,Float64}\n  variables: z (Int64)\n  N° reals:  10"

  d = CartesianGrid(10, 10)
  r = (z=[1:100 for i in 1:10],)
  s = Ensemble(d, r)
  @test domain(s) == d
  @test s[:z] == r[:z]
  for i in 1:10
    @test s[i] == georef((z=1:100,), d)
  end

  @test sprint(show, s) == "2D Ensemble"
  @test sprint(show, MIME"text/plain"(), s) ==
        "2D Ensemble\n  domain:    10×10 CartesianGrid{2,Float64}\n  variables: z (Int64)\n  N° reals:  10"

  grid = CartesianGrid(3, 3)
  reals = (z=[i * ones(nelements(grid)) for i in 1:3],)
  ensemble = Ensemble(grid, reals)

  # mean
  mean2D = mean(ensemble)
  @test mean2D.z == 2.0 * ones(nrow(mean2D))
  @test domain(mean2D) == domain(ensemble)

  # variance
  var2D = var(ensemble)
  @test var2D.z == 1.0 * ones(nrow(var2D))
  @test domain(var2D) == domain(ensemble)

  # quantile (scalar)
  p = 0.5
  quant2D = quantile(ensemble, p)
  @test quant2D.z == 2.0 * ones(nrow(quant2D))
  @test domain(quant2D) == domain(ensemble)

  # quantile (vector)
  ps = [0.0, 0.5, 1.0]
  quants2D = quantile(ensemble, ps)
  @test quants2D[2].z == quant2D.z
end

@testset "Ensembles" begin
  d = PointSet(rand(2,100))
  r = Dict(:z => [1:100 for i in 1:10])
  s = Ensemble(d, r)
  @test s[:z] == r[:z]

  @test sprint(show, s) == "2D Ensemble"
  @test sprint(show, MIME"text/plain"(), s) == "2D Ensemble\n  domain: 100 PointSet{2,Float64}\n  variables: z\n  N° reals:  10"

  d = CartesianGrid(10,10)
  s = Ensemble(d, r)

  @test sprint(show, s) == "2D Ensemble"
  @test sprint(show, MIME"text/plain"(), s) == "2D Ensemble\n  domain: 10×10 CartesianGrid{2,Float64}\n  variables: z\n  N° reals:  10"

  if visualtests
    @test_reference "data/ensemble.png" plot(s,size=(800,300))
  end
end

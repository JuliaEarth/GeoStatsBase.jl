@testset "Solutions" begin
  @testset "Estimation" begin
    d = PointSet(rand(2,100))
    m = Dict(:z => 1:100)
    v = Dict(:z => 1:100)
    s = EstimationSolution(d, m, v)
    @test s[:z] == georef((z=1:100, zvar=1:100), d)

    @test sprint(show, s) == "2D EstimationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D EstimationSolution\n  domain: 100 PointSet{Float64,2}\n  variables: z"

    d = RegularGrid(10,10)
    s = EstimationSolution(d, m, v)
    @test s[:z] == georef((z=1:100, zvar=1:100), d)

    @test sprint(show, s) == "2D EstimationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D EstimationSolution\n  domain: 10×10 RegularGrid{Float64,2}\n  variables: z"

    if visualtests
      @plottest plot(s,size=(800,400)) joinpath(datadir,"estimsol.png") !isCI
    end
  end

  @testset "Simulation" begin
    d = PointSet(rand(2,100))
    r = Dict(:z => [1:100 for i in 1:10])
    s = SimulationSolution(d, r)
    @test s[:z] == r[:z]

    @test sprint(show, s) == "2D SimulationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D SimulationSolution\n  domain: 100 PointSet{Float64,2}\n  variables: z\n  N° reals:  10"

    d = RegularGrid(10,10)
    s = SimulationSolution(d, r)

    @test sprint(show, s) == "2D SimulationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D SimulationSolution\n  domain: 10×10 RegularGrid{Float64,2}\n  variables: z\n  N° reals:  10"

    if visualtests
      @plottest plot(s,size=(800,300)) joinpath(datadir,"simsol.png") !isCI
    end
  end
end

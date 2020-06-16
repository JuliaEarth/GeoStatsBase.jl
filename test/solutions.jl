@testset "Solutions" begin
  @testset "Estimation" begin
    d = PointSet(rand(2,100))
    m = Dict(:z => 1:100)
    v = Dict(:z => 1:100)
    s = EstimationSolution(d, m, v)
    @test s[:z] == (mean=1:100, variance=1:100)

    @test sprint(show, s) == "2D EstimationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D EstimationSolution\n  domain: 100 PointSet{Float64,2}\n  variables: z"

    d = RegularGrid{Float64}(10,10)
    s = EstimationSolution(d, m, v)
    @test s[:z] == (mean=reshape(1:100,10,10), variance=reshape(1:100,10,10))

    @test sprint(show, s) == "2D EstimationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D EstimationSolution\n  domain: 10×10 RegularGrid{Float64,2}\n  variables: z"

    if visualtests
      @plottest plot(s,size=(800,400)) joinpath(datadir,"estimsol.png") !istravis
    end
  end

  @testset "Simulation" begin
    d = PointSet(rand(2,100))
    r = Dict(:z => [1:100 for i in 1:10])
    s = SimulationSolution(d, r)
    @test s[:z] == r[:z]

    @test sprint(show, s) == "2D SimulationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D SimulationSolution\n  domain: 100 PointSet{Float64,2}\n  variables: z\n  N° reals:  10"

    d = RegularGrid{Float64}(10,10)
    s = SimulationSolution(d, r)

    @test sprint(show, s) == "2D SimulationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D SimulationSolution\n  domain: 10×10 RegularGrid{Float64,2}\n  variables: z\n  N° reals:  10"

    if visualtests
      @plottest plot(s,size=(800,300)) joinpath(datadir,"simsol.png") !istravis
    end
  end

  @testset "Learning" begin
    # TODO
  end
end

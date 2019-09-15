@testset "Solutions" begin
  @testset "Estimation" begin
    d = PointSet(rand(2,100))
    m = Dict(:z => 1:100)
    v = Dict(:z => 1:100)
    s = EstimationSolution(d, m, v)
    @test s[:z] == (mean=1:100, variance=1:100)

    d = RegularGrid{Float64}(10,10)
    s = EstimationSolution(d, m, v)
    @test s[:z] == (mean=reshape(1:100,10,10), variance=reshape(1:100,10,10))

    @test sprint(show, s) == "2D EstimationSolution"
    @test sprint(show, MIME"text/plain"(), s) == "2D EstimationSolution\n  domain: 10×10 RegularGrid{Float64,2}\n  variables: z"

    if visualtests
      gr(size=(800,400))
      @plottest plot(s) joinpath(datadir,"EstimationSolution.png") !istravis
    end
  end

  @testset "Simulation" begin
    # TODO
  end

  @testset "Learning" begin
    # TODO
  end
end

@testset "Solvers" begin
  @testset "CookieCutter" begin
    problem = SimulationProblem(RegularGrid{Float64}(100,100), (:facies => Int, :property => Float64), 3)
    solver = CookieCutter(Dummy(:facies => NamedTuple()), [0 => Dummy(), 1 => Dummy()])

    Random.seed!(1234)
    solution = solve(problem, solver)

    if visualtests
      gr(size=(800,600))
      @plottest plot(solution) joinpath(datadir,"CookieCutter.png") !istravis
    end
  end
end

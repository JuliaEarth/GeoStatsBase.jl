@testset "Solvers" begin
  grid = CartesianGrid(10,10)
  vars = (:Z1=>Float64,:Z2=>Float64,:Z3=>Float64)
  prob = SimulationProblem(grid, vars, 1)
  solv = SSolver()
  covars = covariables(prob, solv)
  @test covars[1].names == (:Z1,)
  @test covars[2].names == (:Z2,)
  @test covars[3].names == (:Z3,)
  sol = solve(prob, solv)
  @test sprint(show, sol) == "2D Ensemble"
  @test sprint(show, MIME"text/plain"(), sol) == "2D Ensemble\n  domain: 10×10 CartesianGrid{2,Float64}\n  variables: Z1, Z2 and Z3\n  N° reals:  1"
end

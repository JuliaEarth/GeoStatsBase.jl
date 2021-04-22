@testset "Solvers" begin
  grid = CartesianGrid(10,10)
  vars = (:Z1=>Float64,:Z2=>Float64,:Z3=>Float64)
  prob = SimulationProblem(grid, vars, 1)
  solv = SSolver()
  covars = covariables(prob, solv)
  @test covars[1].names == (:Z1,)
  @test covars[2].names == (:Z2,)
  @test covars[3].names == (:Z3,)
end

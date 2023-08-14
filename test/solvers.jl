@testset "Solvers" begin
  grid = CartesianGrid(10, 10)
  vars = (:Z1 => Float64, :Z2 => Float64, :Z3 => Float64)
  prob = SimulationProblem(grid, vars, 1)

  solver = SSolver()
  covars = covariables(prob, solver)
  @test covars[1].names == Set([:Z1])
  @test covars[2].names == Set([:Z2])
  @test covars[3].names == Set([:Z3])
  @test covars[1].params[Set([:Z1])].A == 1.0
  @test covars[1].params[Set([:Z1])].B == 2
  @test covars[2].params[Set([:Z2])].A == 1.0
  @test covars[2].params[Set([:Z2])].B == 2
  @test covars[3].params[Set([:Z3])].A == 1.0
  @test covars[3].params[Set([:Z3])].B == 2
  @test sprint(show, MIME"text/plain"(), solver) == "SSolver\n"
  sol = solve(prob, solver)
  @test sol isa Ensemble

  solver = SSolver(:Z1 => (A=2.0, B=3), :Z2 => (A=3.0, B=4), (:Z1, :Z2) => (J="bar",))
  covars = covariables(prob, solver)
  @test covars[1].names == Set([:Z1, :Z2])
  @test covars[2].names == Set([:Z3])
  @test covars[1].params[Set([:Z1])].A == 2.0
  @test covars[1].params[Set([:Z1])].B == 3
  @test covars[1].params[Set([:Z1, :Z2])].J == "bar"
  @test covars[2].params[Set([:Z3])].A == 1.0
  @test covars[2].params[Set([:Z3])].B == 2
  @test sprint(show, MIME"text/plain"(), solver) ==
        "SSolver\n  └─Z2\n    └─A ⇨ 3.0\n    └─B ⇨ 4\n  └─Z1\n    └─A ⇨ 2.0\n    └─B ⇨ 3\n  └─Z2—Z1\n    └─J ⇨ \"bar\"\n"
  sol = solve(prob, solver)
  @test sol isa Ensemble
end

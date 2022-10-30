@testset "Problems" begin
  data2D = georef(CSV.File(joinpath(datadir,"data2D.tsv")), (:x,:y))
  data3D = georef(CSV.File(joinpath(datadir,"data3D.tsv")), (:x,:y,:z))
  grid2D = CartesianGrid(100,100)
  grid3D = CartesianGrid(100,100,100)

  @testset "Estimation" begin
    # test basic problem interface
    problem3D = EstimationProblem(data3D, grid3D, :value)
    @test data(problem3D) == data3D
    @test domain(problem3D) == grid3D
    @test variables(problem3D) == (Variable(:value, Float64),)

    # problems with missing data have types inferred correctly
    Z = Array{Union{Float64,Missing}}(rand(10,10))
    problem = EstimationProblem(georef((Z=Z,)), grid2D, :Z)
    @test variables(problem) == (Variable(:Z, Float64),)

    # show methods
    problem2D = EstimationProblem(data2D, grid2D, :value)
    @test sprint(show, problem2D) == "2D EstimationProblem"
    @test sprint(show, MIME"text/plain"(), problem2D) == "2D EstimationProblem\n  data:      3 MeshData{2,Float64}\n  domain:    100×100 CartesianGrid{2,Float64}\n  variables: value (Float64)"
  end

  @testset "Simulation" begin
    # test basic problem interface
    problem3D = SimulationProblem(data3D, grid3D, :value, 100)
    @test data(problem3D) == data3D
    @test domain(problem3D) == grid3D
    @test variables(problem3D) == (Variable(:value, Float64),)
    @test hasdata(problem3D)
    @test nreals(problem3D) == 100

    # problems with missing data have types inferred correctly
    Z = Array{Union{Float64,Missing}}(rand(10,10))
    problem = SimulationProblem(georef((Z=Z,)), grid2D, :Z, 3)
    @test variables(problem) == (Variable(:Z, Float64),)

    # specify type of variable explicitly
    problem = SimulationProblem(data3D, grid3D, :value => Float64, 100)
    @test variables(problem) == (Variable(:value, Float64),)

    # add variable not present in spatial data
    problem = SimulationProblem(data3D, grid3D, (:value => Float64, :other => Int), 100)
    @test variables(problem) == (Variable(:value, Float64), Variable(:other, Int))

    # infer type of variables in spatial data whenever possible
    problem = SimulationProblem(data3D, grid3D, (:value, :other => Int), 100)
    @test variables(problem) == (Variable(:value, Float64), Variable(:other, Int))

    # constructors without spatial data require variables with types
    problem = SimulationProblem(grid3D, :value => Float64, 100)
    @test variables(problem) == (Variable(:value, Float64),)
    @test_throws MethodError SimulationProblem(grid3D, :value, 100)

    # show methods
    problem2D = SimulationProblem(data2D, grid2D, :value, 100)
    @test sprint(show, problem2D) == "2D SimulationProblem (conditional)"
    @test sprint(show, MIME"text/plain"(), problem2D) == "2D SimulationProblem (conditional)\n  data:      3 MeshData{2,Float64}\n  domain:    100×100 CartesianGrid{2,Float64}\n  variables: value (Float64)\n  N° reals:  100"
  end

  @testset "Learning" begin
    rng   = MersenneTwister(42)
    sdata = georef((x=rand(rng,10),y=rand(rng,10),z=rand(rng,10)), 10rand(rng,2,10))
    tdata = georef((x=rand(rng,10,10),))
    rtask = RegressionTask(:x, :y)
    ctask = ClassificationTask(:x, :y)

    # test basic problem interface
    problem = LearningProblem(sdata, tdata, rtask)
    @test sourcedata(problem) == sdata
    @test targetdata(problem) == tdata
    @test task(problem) == rtask

    # show methods
    problem = LearningProblem(sdata, tdata, ctask)
    @test sprint(show, problem) == "2D LearningProblem"
    @test sprint(show, MIME"text/plain"(), problem) == "2D LearningProblem\n  source: 10 MeshData{2,Float64}\n  target: 100 MeshData{2,Float64}\n  task:   Classification x → y"
  end
end

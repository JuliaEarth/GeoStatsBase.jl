@testset "Problems" begin
  data2D = readgeotable(joinpath(datadir,"data2D.tsv"), coordnames=(:x,:y))
  data3D = readgeotable(joinpath(datadir,"data3D.tsv"))
  grid2D = RegularGrid(100,100)
  grid3D = RegularGrid(100,100,100)

  @testset "Estimation" begin
    # test basic problem interface
    problem3D = EstimationProblem(data3D, grid3D, :value)
    @test data(problem3D) == data3D
    @test domain(problem3D) == grid3D
    @test variables(problem3D) == (Variable(:value, Float64),)

    # problems with missing data have types inferred correctly
    img = Array{Union{Float64,Missing}}(rand(10,10))
    mdata = georef((var=img,))
    problem = EstimationProblem(mdata, grid2D, :var)
    @test variables(problem) == (Variable(:var, Float64),)

    # show methods
    problem2D = EstimationProblem(data2D, grid2D, :value)
    @test sprint(show, problem2D) == "2D EstimationProblem"
    @test sprint(show, MIME"text/plain"(), problem2D) == "2D EstimationProblem\n  data:      3 SpatialData{Float64,2}\n  domain:    100×100 RegularGrid{Float64,2}\n  variables: value (Float64)"

    if visualtests
      @plottest plot(problem2D,ms=2) joinpath(datadir,"estimation.png") !istravis
    end
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
    img = Array{Union{Float64,Missing}}(rand(10,10))
    mdata = georef((var=img,))
    problem = SimulationProblem(mdata, grid2D, :var, 3)
    @test variables(problem) == (Variable(:var, Float64),)

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
    @test sprint(show, MIME"text/plain"(), problem2D) == "2D SimulationProblem (conditional)\n  data:      3 SpatialData{Float64,2}\n  domain:    100×100 RegularGrid{Float64,2}\n  variables: value (Float64)\n  N° reals:  100"

    if visualtests
      @plottest plot(problem2D,ms=2) joinpath(datadir,"simulation.png") !istravis
    end
  end

  @testset "Learning" begin
    Random.seed!(123)
    sdata = georef((x=rand(10),y=rand(10),z=rand(10)), 10rand(2,10))
    tdata = georef((x=rand(10,10),))
    rtask = RegressionTask(:x, :y)
    ctask = ClusteringTask(:x, :c)

    # test basic problem interface
    problem = LearningProblem(sdata, tdata, rtask)
    @test sourcedata(problem) == sdata
    @test targetdata(problem) == tdata
    @test task(problem) == rtask

    # show methods
    problem = LearningProblem(sdata, tdata, ctask)
    @test sprint(show, problem) == "2D LearningProblem"
    @test sprint(show, MIME"text/plain"(), problem) == "2D LearningProblem\n  source: 10 SpatialData{Float64,2}\n  target: 100 SpatialData{Float64,2}\n  task:   Clustering x → c"

    if visualtests
      @plottest plot(problem,ms=2) joinpath(datadir,"learning.png") !istravis
    end
  end
end

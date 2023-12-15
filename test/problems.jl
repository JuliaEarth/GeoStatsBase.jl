@testset "Problems" begin
  data2D = georef(CSV.File(joinpath(datadir, "data2D.tsv")), (:x, :y))
  data3D = georef(CSV.File(joinpath(datadir, "data3D.tsv")), (:x, :y, :z))
  grid2D = CartesianGrid(100, 100)
  grid3D = CartesianGrid(100, 100, 100)

  @testset "Interpolation" begin
    # test basic problem interface
    problem3D = InterpProblem(data3D, grid3D, :value)
    @test data(problem3D) == data3D
    @test domain(problem3D) == grid3D
    @test variables(problem3D) == (; value=Float64)

    # problems with missing data have types inferred correctly
    Z = Array{Union{Float64,Missing}}(rand(10, 10))
    problem = InterpProblem(georef((Z=Z,)), grid2D, :Z)
    @test variables(problem) == (; Z=Float64)

    # show methods
    problem2D = InterpProblem(data2D, grid2D, :value)
    @test sprint(show, problem2D) == "2D InterpProblem"
    @test sprint(show, MIME"text/plain"(), problem2D) ==
          "2D InterpProblem\n  domain:    100×100 CartesianGrid{2,Float64}\n  samples:   3 PointSet{2,Float64}\n  targets:   value (Float64)"
  end

  @testset "Learning" begin
    rng = MersenneTwister(42)
    sdata = georef((x=rand(rng, 10), y=rand(rng, 10), z=rand(rng, 10)), 10rand(rng, 2, 10))
    tdata = georef((x=rand(rng, 10, 10),))
    rtask = RegressionTask(:x, :y)
    ctask = ClassificationTask(:x, :y)

    # test basic problem interface
    problem = LearnProblem(sdata, tdata, rtask)
    @test sourcedata(problem) == sdata
    @test targetdata(problem) == tdata
    @test task(problem) == rtask

    # show methods
    problem = LearnProblem(sdata, tdata, ctask)
    @test sprint(show, problem) == "2D LearnProblem"
    @test sprint(show, MIME"text/plain"(), problem) ==
          "2D LearnProblem\n  source: 10 PointSet{2,Float64}\n  target: 10×10 CartesianGrid{2,Float64}\n  task:   Classification x → y"
  end
end

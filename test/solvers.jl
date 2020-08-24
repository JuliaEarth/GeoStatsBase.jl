@testset "Solvers" begin
  @testset "CookieCutter" begin
    problem = SimulationProblem(RegularGrid(100,100), (:facies => Int, :property => Float64), 3)
    solver = CookieCutter(DummySimSolver(:facies => NamedTuple()),
                          Dict(0=>DummySimSolver(), 1 => DummySimSolver()))

    @test sprint(show, solver) == "CookieCutter"
    @test sprint(show, MIME"text/plain"(), solver) == "CookieCutter\n  └─facies ⇨ DummySimSolver\n    └─0 ⇨ DummySimSolver\n    └─1 ⇨ DummySimSolver\n"

    Random.seed!(1234)
    solution = solve(problem, solver)

    if visualtests
      @plottest plot(solution,size=(800,600)) joinpath(datadir,"cookiecutter.png") !istravis
    end
  end

  @testset "SeqSim" begin
    problem = SimulationProblem(RegularGrid(100,100), :var => Float64, 3)
    solver = SeqSim(:var => (estimator=DummyEstimator(),
                             neighborhood=BallNeighborhood(10.),
                             minneighbors=1, maxneighbors=10,
                             marginal=Normal(), path=LinearPath()))

    Random.seed!(1234)
    solution = solve(problem, solver)

    if visualtests
      @plottest plot(solution,size=(900,300)) joinpath(datadir,"seqsim.png") !istravis
    end
  end

  @testset "PointwiseLearn" begin
    Random.seed!(1234)
    f(x,y) = sin(4*(abs(x)+abs(y))) < 0 ? 1 : 0 
    X = [sin(i/10) for i in 1:100, j in 1:100]
    Y = [sin(j/10) for i in 1:100, j in 1:100]
    Z = categorical(f.(X,Y))
    ϵ₁ = 0.1randn(Float64, size(X))
    ϵ₂ = 0.1randn(Float64, size(Y))

    S = georef((X=X,Y=Y,Z=Z))
    T = georef((X=X+ϵ₁,Y=Y+ϵ₂))
    𝓉 = ClassificationTask((:X,:Y), :Z)
    𝒫 = LearningProblem(S, T, 𝓉)

    m = @load DecisionTreeClassifier
    ℒ = PointwiseLearn(m)

    T̂ = solve(𝒫, ℒ)

    err = mean(S[:Z] .!= T̂[:Z])
    @test err < 0.15

    if visualtests
      @plottest begin
        p1 = plot(S, (:Z,))
        p2 = plot(T̂)
        plot(p1, p2, size=(800,400))
      end joinpath(datadir,"pointlearn.png") !istravis
    end
  end
end

@testset "Solvers" begin
  @testset "CookieCutter" begin
    problem = SimulationProblem(RegularGrid(100,100), (:facies => Int, :property => Float64), 3)
    solver = CookieCutter(DummySimSolver(:facies=>NamedTuple()),
                          Dict(0=>DummySimSolver(), 1=>DummySimSolver()))

    @test sprint(show, solver) == "CookieCutter"
    @test sprint(show, MIME"text/plain"(), solver) == "CookieCutter\n  └─facies ⇨ DummySimSolver\n    └─0 ⇨ DummySimSolver\n    └─1 ⇨ DummySimSolver\n"

    Random.seed!(1234)
    solution = solve(problem, solver)

    if visualtests
      @plottest plot(solution,size=(800,600)) joinpath(datadir,"cookiecutter.png") !isCI
    end
  end

  @testset "SeqSim" begin
    Random.seed!(1234)
    sdata = georef((z=rand(100),), 100*rand(2,100))
    sgrid = RegularGrid(100,100)

    prob1 = SimulationProblem(sgrid, :z => Float64, 3)
    prob2 = SimulationProblem(sdata, sgrid, :z, 3)

    solver = SeqSim(:z => (estimator=DummyEstimator(),
                           neighborhood=BallNeighborhood(10.),
                           minneighbors=1, maxneighbors=10,
                           marginal=Normal(), path=LinearPath(),
                           mapping=NearestMapping()))

    Random.seed!(1234)
    usol = solve(prob1, solver)
    csol = solve(prob2, solver)

    if visualtests
      @plottest plot(usol,size=(900,300)) joinpath(datadir,"seqsim.png") !isCI
    end
  end

  @testset "PointwiseLearn" begin
    # synthetic data
    Random.seed!(1234)
    f(x,y) = sin(4*(abs(x)+abs(y))) < 0 ? 1 : 0 
    X = [sin(i/10) for i in 1:100, j in 1:100]
    Y = [sin(j/10) for i in 1:100, j in 1:100]
    Z = categorical(f.(X,Y))
    ϵ₁ = 0.1randn(Float64, size(X))
    ϵ₂ = 0.1randn(Float64, size(Y))

    # source and target data
    S = georef((X=X,Y=Y,Z=Z))
    T = georef((X=X+ϵ₁,Y=Y+ϵ₂))

    # view versions
    inds = shuffle(1:nelms(S))
    Sv = view(S, inds)
    Tv = view(T, inds)

    # classification task
    𝓉 = ClassificationTask((:X,:Y), :Z)

    # learning problems
    𝒫₁ = LearningProblem(S, T, 𝓉)
    𝒫₂ = LearningProblem(Sv, Tv, 𝓉)

    # pointwise solver
    ℒ = PointwiseLearn(dtree)

    R₁ = solve(𝒫₁, ℒ)
    R₂ = solve(𝒫₂, ℒ)

    # error is small
    @test mean(S[:Z] .!= R₁[:Z]) < 0.15
    @test mean(Sv[:Z] .!= R₂[:Z]) < 0.15

    if visualtests
      for (i,s) in enumerate([(S,R₁), (Sv,R₂)])
        @plottest begin
          p1 = plot(s[1], (:Z,))
          p2 = plot(s[2])
          plot(p1, p2, size=(800,400))
        end joinpath(datadir,"pointlearn$i.png") !isCI
      end
    end
  end
end

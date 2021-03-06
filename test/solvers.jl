@testset "Solvers" begin
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
    inds = shuffle(1:nelements(S))
    Sv = view(S, inds)
    Tv = view(T, inds)

    # classification task
    𝓉 = ClassificationTask((:X,:Y), :Z)

    # learning problems
    𝒫₁ = LearningProblem(S, T, 𝓉)
    𝒫₂ = LearningProblem(Sv, Tv, 𝓉)

    # pointwise solver
    ℒ = PointwiseLearn(dtree())

    R₁ = solve(𝒫₁, ℒ)
    R₂ = solve(𝒫₂, ℒ)

    # error is small
    @test mean(S[:Z] .!= R₁[:Z]) < 0.15
    @test mean(Sv[:Z] .!= R₂[:Z]) < 0.15

    if visualtests
      for (i,s) in enumerate([(S,R₁), (Sv,R₂)])
        p1 = plot(s[1], (:Z,))
        p2 = plot(s[2])
        plt = plot(p1, p2, size=(800,400))
        @test_reference "data/pointlearn$i.png" plt
      end
    end
  end
end

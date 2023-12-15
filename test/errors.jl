@testset "Errors" begin
  Random.seed!(123)

  @testset "Learning" begin
    x = rand(1:2, 1000)
    y = rand(1:2, 1000)
    X = rand(2, 1000)
    𝒮 = georef((x=x, y=y), X)
    𝒯 = ClassificationTask(:x, :y)
    p = LearnProblem(𝒮, 𝒮, 𝒯)
    s = LearnSetup(Learn, DecisionTreeClassifier())

    # dummy classifier → 0.5 misclassification rate
    for m in [LeaveOneOut(), LeaveBallOut(0.1), KFoldValidation(10), BlockValidation(0.1), DensityRatioValidation(10)]
      e = error(s, p, m)
      @test isapprox(e[:y], 0.5, atol=0.06)
    end
  end

  @testset "Interpolation" begin
    ℐ₁ = georef((z=rand(50, 50),))
    ℐ₂ = georef((z=100rand(50, 50),))
    𝒮₁ = sample(ℐ₁, UniformSampling(100, replace=false))
    𝒮₂ = sample(ℐ₂, UniformSampling(100, replace=false))
    p₁ = InterpProblem(𝒮₁, domain(ℐ₁), :z)
    p₂ = InterpProblem(𝒮₂, domain(ℐ₂), :z)
    s = InterpSetup(Interpolate, NN())

    # low variance + dummy (mean) estimator → low error
    # high variance + dummy (mean) estimator → high error
    for m in [LeaveOneOut(), LeaveBallOut(0.1), KFoldValidation(10), BlockValidation(0.1)]
      e₁ = error(s, p₁, m)
      e₂ = error(s, p₂, m)
      @test e₁[:z] < 1
      @test e₂[:z] > 1
    end
  end
end

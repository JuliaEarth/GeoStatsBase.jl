@testset "Errors" begin
  @testset "Learning" begin
    x = rand(1:2, 1000)
    y = rand(1:2, 1000)
    X = rand(2, 1000)
    d = georef(DataFrame(x=x, y=y), PointSet(X))
    p = LearningProblem(d, d, ClassificationTask(:x, :y))
    s = PointwiseLearn(DummyModel())

    # dummy classifier → 0.5 misclassification rate
    for m in [CrossValidation(10), BlockCrossValidation(0.1),
              LeaveBallOut(0.1), DensityRatioValidation(10)]
      e = error(s, p, m)
      @test isapprox(e[:y], 0.5, atol=0.06)
    end
  end
end

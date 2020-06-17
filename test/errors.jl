@testset "Errors" begin
  x = rand(1:2, 1000)
  y = rand(1:2, 1000)
  X = rand(2, 1000)
  d = PointSetData(OrderedDict(:x=>x,:y=>y),X)
  p = LearningProblem(d, d, ClassificationTask(:x, :y))
  s = PointwiseLearn(DummyModel())

  # random classifer → 0.5 misclassification
  for m in [CrossValidation(10),
            BlockCrossValidation(0.1),
            DensityRatioValidation(10)]
    e = error(s, p, m)
    @test isapprox(e[:y], 0.5, atol=0.05)
  end
end

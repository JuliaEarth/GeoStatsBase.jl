@testset "Learning" begin
  @testset "Tasks" begin
    t = RegressionTask(:x,:y)
    @test inputvars(t) == (:x,)
    @test outputvars(t) == (:y,)
    @test features(t) == (:x,)
    @test label(t) == :y

    t = ClassificationTask(:x,:y)
    @test inputvars(t) == (:x,)
    @test outputvars(t) == (:y,)
    @test features(t) == (:x,)
    @test label(t) == :y

    t = ClusteringTask(:x,:y)
    @test inputvars(t) == (:x,)
    @test outputvars(t) == (:y,)
    @test features(t) == (:x,)
  end
end

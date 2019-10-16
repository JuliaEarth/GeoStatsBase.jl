@testset "Learning" begin
  @testset "Tasks" begin
    t = RegressionTask(:x,:y)
    @test inputvars(t) == (:x,)
    @test outputvars(t) == (:y,)
    @test features(t) == (:x,)
    @test label(t) == :y
    @test sprint(show, t) == "Regression x → y"
    t = RegressionTask([:x,:y], :z)
    @test inputvars(t) == (:x,:y)
    @test features(t) == (:x,:y)
    @test sprint(show, t) == "Regression (x, y) → z"

    t = ClassificationTask(:x,:y)
    @test inputvars(t) == (:x,)
    @test outputvars(t) == (:y,)
    @test features(t) == (:x,)
    @test label(t) == :y
    @test sprint(show, t) == "Classification x → y"
    t = ClassificationTask([:x,:y], :z)
    @test inputvars(t) == (:x,:y)
    @test features(t) == (:x,:y)
    @test sprint(show, t) == "Classification (x, y) → z"

    t = ClusteringTask(:x,:y)
    @test inputvars(t) == (:x,)
    @test outputvars(t) == (:y,)
    @test features(t) == (:x,)
    @test sprint(show, t) == "Clustering x → y"
    t = ClusteringTask([:x,:y], :z)
    @test inputvars(t) == (:x,:y)
    @test features(t) == (:x,:y)
    @test sprint(show, t) == "Clustering (x, y) → z"
  end
end

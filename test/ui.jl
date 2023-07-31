@testset "UI elements" begin
  # search method from user input
  domain = PointSet(rand(2, 3))
  method = searcher_ui(domain, 2, Euclidean(), nothing)
  @test method isa KNearestSearch
  @test maxneighbors(method) == 2
  method = searcher_ui(domain, 2, nothing, MetricBall(1.0))
  @test method isa KBallSearch
  @test maxneighbors(method) == 2
  method = searcher_ui(domain, nothing, nothing, nothing)
  @test method isa GlobalSearch
  @test maxneighbors(method) == 3

  @test_throws ArgumentError searcher_ui(domain, 5, Euclidean(), nothing)
end

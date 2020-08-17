@testset "Geometries" begin
  @testset "Rectangle" begin
    r = Rectangle((1.,1.), (1.,2.))
    @test origin(r) == [1., 1.]
    @test sides(r) == [1., 2.]
    @test origin(r) + sides(r) == [2., 3.]
    @test GeoStatsBase.center(r) == [3/2, 4/2]
    @test GeoStatsBase.diagonal(r) == sqrt(1^2 + 2^2)
    @test volume(r) == 1*2
  end
end
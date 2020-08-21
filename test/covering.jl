@testset "Covering" begin
  @testset "Rectangle" begin
    r = cover(RegularGrid(100, 200), RectangleCoverer())
    @test r == Rectangle((0.,0.), (99.,199.))

    r = cover(PointSet([0. 1. 2.; 0. 2. 1.]), RectangleCoverer())
    @test r == Rectangle((0.,0.), (2.,2.))

    r = cover(PointSet([1. 2.; 2. 1.]), RectangleCoverer())
    @test r == Rectangle((1.,1.), (2.,2.))
  end
end

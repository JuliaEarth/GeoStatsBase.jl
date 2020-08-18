@testset "Views" begin
  @testset "Domain" begin
    d = RegularGrid(10, 10)
    X = coordinates(d)
    v = view(d, 1:10)
    @test npoints(v) == 10
    @test coordinates(v) == X[:,1:10]
    @test collect(v) isa PointSet
  end

  @testset "Data" begin
    d = georef((z=rand(100), w=rand(100)))
    T = values(d)
    X = coordinates(d)
    v = view(d, 1:10)
    @test npoints(v) == 10
    @test coordinates(v) == X[:,1:10]
    @test collect(v) isa SpatialData
  end
end
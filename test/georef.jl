@testset "Georeferencing" begin
  table = DataFrame(x=rand(3), y=[1,2,3], z=["a","b","c"])
  tuple = (x=rand(3), y=[1,2,3], z=["a","b","c"])

  # explicit domain types
  d = georef(table, PointSet(rand(2,3)))
  @test domain(d) isa PointSet
  d = georef(tuple, PointSet(rand(2,3)))
  @test domain(d) isa PointSet
  d = georef(table, RegularGrid(3))
  @test domain(d) isa RegularGrid
  d = georef(tuple, RegularGrid(3))
  @test domain(d) isa RegularGrid

  # coordinates of point set
  d = georef(table, rand(2,3))
  @test domain(d) isa PointSet
  d = georef(tuple, rand(2,3))
  @test domain(d) isa PointSet

  # coordinates names in table
  d = georef(table, (:x,:y))
  @test domain(d) isa PointSet

  # regular grid data
  d = georef(tuple)
  @test domain(d) == RegularGrid(3)
  tuple2D = (x=rand(10,10), y=rand(Int,10,10))
  d = georef(tuple2D)
  @test domain(d) == RegularGrid(10,10)
  d = georef(tuple2D, (1.,2.), (3.,4.))
  @test domain(d) == RegularGrid((10,10), (1.,2.), (3.,4.))
  d = georef(tuple2D, spacing=(3.,4.))
  @test domain(d) == RegularGrid((10,10), (0.,0.), (3.,4.))
  tuple3D = (x=rand(10,10,10), y=rand(10,10,10))
  d = georef(tuple3D)
  @test domain(d) == RegularGrid(10,10,10)
end

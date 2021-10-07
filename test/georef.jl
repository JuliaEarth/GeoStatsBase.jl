@testset "Georeferencing" begin
  table = Table(x=rand(3), y=[1,2,3], z=["a","b","c"])
  tuple = (x=rand(3), y=[1,2,3], z=["a","b","c"])

  # explicit domain types
  d = georef(table, PointSet(rand(2,3)))
  @test domain(d) isa PointSet
  d = georef(tuple, PointSet(rand(2,3)))
  @test domain(d) isa PointSet
  d = georef(table, CartesianGrid(3))
  @test domain(d) isa CartesianGrid
  d = georef(tuple, CartesianGrid(3))
  @test domain(d) isa CartesianGrid

  # coordinates of point set
  d = georef(table, rand(2,3))
  @test domain(d) isa PointSet
  d = georef(tuple, rand(2,3))
  @test domain(d) isa PointSet

  # coordinates names in table
  d = georef(table, (:x,:y))
  @test domain(d) isa PointSet

  # coordinates names in named tuple
  d = georef((a=rand(10), b=rand(10), c=rand(10)), (:b,:c))
  @test domain(d) isa PointSet
  @test Tables.columnnames(values(d)) == (:a,)

  # regular grid data
  d = georef(tuple)
  @test domain(d) == CartesianGrid(3)
  tuple2D = (x=rand(10,10), y=rand(Int,10,10))
  d = georef(tuple2D)
  @test domain(d) == CartesianGrid(10,10)
  d = georef(tuple2D, (1.,2.), (3.,4.))
  @test domain(d) == CartesianGrid((10,10), (1.,2.), (3.,4.))
  d = georef(tuple2D, spacing=(3.,4.))
  @test domain(d) == CartesianGrid((10,10), (0.,0.), (3.,4.))
  tuple3D = (x=rand(10,10,10), y=rand(10,10,10))
  d = georef(tuple3D)
  @test domain(d) == CartesianGrid(10,10,10)
end

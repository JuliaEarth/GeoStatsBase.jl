@testset "Georeferencing" begin
  table = Table(x=rand(3), y=[1, 2, 3], z=["a", "b", "c"])
  tuple = (x=rand(3), y=[1, 2, 3], z=["a", "b", "c"])

  # explicit domain types
  d = georef(table, PointSet(rand(2, 3)))
  @test domain(d) isa PointSet
  d = georef(tuple, PointSet(rand(2, 3)))
  @test domain(d) isa PointSet
  d = georef(table, CartesianGrid(3))
  @test domain(d) isa CartesianGrid
  d = georef(tuple, CartesianGrid(3))
  @test domain(d) isa CartesianGrid

  # vectors of geometries
  d = georef(table, rand(Point2, 3))
  @test domain(d) isa PointSet
  d = georef(tuple, rand(Point2, 3))
  @test domain(d) isa PointSet
  d = georef(table, collect(CartesianGrid(3)))
  @test domain(d) isa GeometrySet
  d = georef(tuple, collect(CartesianGrid(3)))
  @test domain(d) isa GeometrySet

  # coordinates of point set
  d = georef(table, rand(2, 3))
  @test domain(d) isa PointSet
  d = georef(tuple, rand(2, 3))
  @test domain(d) isa PointSet

  # coordinates names in table
  d = georef(table, (:x, :y))
  @test domain(d) isa PointSet

  # coordinates names in named tuple
  d = georef((a=rand(10), b=rand(10), c=rand(10)), (:b, :c))
  @test domain(d) isa PointSet
  @test Tables.columnnames(values(d)) |> collect == [:a]

  # regular grid data
  tuple1D = (x=rand(10), y=rand(10))
  d = georef(tuple1D)
  @test domain(d) == CartesianGrid(10)
  tuple2D = (x=rand(10, 10), y=rand(10, 10))
  d = georef(tuple2D)
  @test domain(d) == CartesianGrid(10, 10)
  tuple3D = (x=rand(10, 10, 10), y=rand(10, 10, 10))
  d = georef(tuple3D)
  @test domain(d) == CartesianGrid(10, 10, 10)
end

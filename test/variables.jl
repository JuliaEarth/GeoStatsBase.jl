@testset "Variables" begin
  data = georef((a=[1, 2, 3, 4], b=[5, missing, 7, 8]), CartesianGrid(2, 2))
  @test variables(data) == (Variable(:a, Int), Variable(:b, Int))
  @test name.(variables(data)) == (:a, :b)
  @test mactype.(variables(data)) == (Int, Int)
end

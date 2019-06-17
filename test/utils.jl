@testset "Utilities" begin
  @test_throws ArgumentError readgeotable("doesnotexist.csv")
  @test_throws AssertionError readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t', coordnames=[:a])

  data1D = readgeotable(joinpath(datadir,"data1D.tsv"), delim='\t', coordnames=[:x])
  grid = RegularGrid(bounds(data1D), dims=(100,))
  @test coordinates(grid, 1) == [0.]
  @test coordinates(grid, 100) == [100.]
end

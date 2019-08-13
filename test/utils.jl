@testset "Utilities" begin
  @test_throws ArgumentError readgeotable("doesnotexist.csv")
  @test_throws AssertionError readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t', coordnames=[:a])
end

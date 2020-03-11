@testset "Utilities" begin
  @test_throws ArgumentError readgeotable("doesnotexist.csv")
  @test_throws AssertionError readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t', coordnames=[:a])

  # TODO: test split
  # TODO: test groupby
  # TODO: test boundbox
  # TODO: test join
  # TODO: test sample
  # TODO: test uniquecoords
end

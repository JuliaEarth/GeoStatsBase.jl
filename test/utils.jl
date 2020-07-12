@testset "Utilities" begin
  @test_throws ArgumentError readgeotable("doesnotexist.csv")
  @test_throws AssertionError readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t', coordnames=(:a,))

  @testset "split" begin
    d = RegularGrid(10,10)
    l, r = split(d, 0.5)
    @test npoints(l) == 50
    @test npoints(r) == 50
    l, r = split(d, 0.5, (1.,0.))
    @test npoints(l) == 50
    @test npoints(r) == 50
    cl = mean(coordinates(l), dims=2)
    cr = mean(coordinates(r), dims=2)
    @test cl[1] < cr[1]
    @test cl[2] == cr[2]
    l, r = split(d, 0.5, (0.,1.))
    @test npoints(l) == 50
    @test npoints(r) == 50
    cl = mean(coordinates(l), dims=2)
    cr = mean(coordinates(r), dims=2)
    @test cl[1] == cr[1]
    @test cl[2] < cr[2]
  end

  # TODO: test groupby
  # TODO: test boundbox
  # TODO: test join
  # TODO: test sample
  # TODO: test uniquecoords

  @testset "spheredir" begin
    @test spheredir(90, 0) ≈ [1,0,0]
    @test spheredir(90,90) ≈ [0,1,0]
    @test spheredir(0,  0) ≈ [0,0,1]
  end
end

@testset "Utilities" begin
  @test_throws ArgumentError readgeotable("doesnotexist.csv")
  @test_throws AssertionError readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t', coordnames=(:a,))

  @testset "spheredir" begin
    @test spheredir(90, 0) ≈ [1,0,0]
    @test spheredir(90,90) ≈ [0,1,0]
    @test spheredir(0,  0) ≈ [0,0,1]
  end

  @testset "aniso2distance" begin
    x, y = rand(2), rand(2)
    d = aniso2distance([1.0,1.0], [0.0])
    @test evaluate(d, [0,0], [1,0]) == 1
    @test evaluate(d, [0,0], [0,1]) == 1
    @test evaluate(d, x, y) ≈ euclidean(x, y)
  end
end

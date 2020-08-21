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

  @testset "groupby" begin
    d = georef((z=[1,2,3],x=[4,5,6]), rand(2,3))
    g = groupby(d, :z)
    @test all(npoints.(g) .== 1)
    for i in 1:3
      @test collect(g[i][1]) ∈ [[1,4],[2,5],[3,6]]
    end
  end

  @testset "boundbox" begin
    d = RegularGrid((10,10), (1.,1.), (1.,1.))
    b = boundbox(d)
    @test origin(b) == [1.,1.]
    @test origin(b) + sides(b) == [10.,10.]
  end

  @testset "join" begin
    coords = rand(2,3)
    d1 = georef((x=[1,2,3],), coords)
    d2 = georef((y=[4.,5.,6.],), coords)
    d = join(d1, d2)
    vars = variables(d)
    @test vars[1] == Variable(:x, Int)
    @test vars[2] == Variable(:y, Float64)
    @test d[:x] == [1,2,3]
    @test d[:y] == [4.,5.,6.]
  end

  @testset "sample" begin
    d = georef((z=rand(10,10),))
    s = sample(d, 50)
    @test npoints(s) == 50
    s = sample(d, 50, rand([1,2], 100))
    @test npoints(s) == 50
  end

  @testset "filter" begin
    𝒟 = georef((a=[1,2,3], b=[1,1,missing]))
    𝒫 = filter(s -> !ismissing(s.b), 𝒟)
    @test 𝒫[:a] == [1,2]
    @test 𝒫[:b] == [1,1]

    𝒟 = georef((a=[1,2,3],b=[3,2,1]))
    𝒫ₐ = filter(s -> s.a > 1, 𝒟)
    𝒫ᵦ = filter(s -> s.b > 1, 𝒟)
    𝒫ₐᵦ = filter(s -> s.a > 1 && s.b > 1, 𝒟)
    @test npoints(𝒫ₐ) == 2
    @test npoints(𝒫ᵦ) == 2
    @test npoints(𝒫ₐᵦ) == 1
    @test 𝒫ₐ[:a] == [2,3]
    @test 𝒫ₐ[:b] == [2,1]
    @test 𝒫ᵦ[:a] == [1,2]
    @test 𝒫ᵦ[:b] == [3,2]
    @test 𝒫ₐᵦ[:a] == [2]
    @test 𝒫ₐᵦ[:b] == [2]
  end

  @testset "spheredir" begin
    @test spheredir(90, 0) ≈ [1,0,0]
    @test spheredir(90,90) ≈ [0,1,0]
    @test spheredir(0,  0) ≈ [0,0,1]
  end
end

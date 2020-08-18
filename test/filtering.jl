@testset "Filtering" begin
  @testset "UniqueCoordsFilter" begin
    X = rand(3,100)
    z = rand(100)
    n = [string(i) for i in 1:100]
    Xd = hcat(X, X[:,1:10])
    zd = vcat(z, z[1:10])
    nd = vcat(n, n[1:10])
    sdata = georef(DataFrame(z=zd, n=nd), PointSet(Xd))
    ndata = filter(sdata, UniqueCoordsFilter())
    @test npoints(ndata) == 100
  end

  @testset "PredicateFilter" begin
    𝒟 = georef((a=[1,2,3],b=[3,2,1]))
    𝒫ₐ = filter(𝒟, PredicateFilter(s -> s.a > 1))
    𝒫ᵦ = filter(𝒟, PredicateFilter(s -> s.b > 1))
    𝒫ₐᵦ = filter(𝒟, PredicateFilter(s -> s.a > 1 && s.b > 1))
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

  @testset "GeometryFilter" begin
    𝒟 = RegularGrid(10,10)
    𝒮 = georef((z=rand(100),), 𝒟)
    ℱ = GeometryFilter(Rectangle((1.,1.),(10.,10.)))
    𝒫 = filter(𝒟, ℱ)
    𝒱 = filter(𝒮, ℱ)
    @test npoints(𝒫) == 81
    @test npoints(𝒫) == 81
  end
end

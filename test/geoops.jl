@testset "Geometric operations" begin
  @testset "cat" begin
    d₁ = RegularGrid(10,10)
    d₂ = PointSet(rand(2,10))
    d = vcat(d₁, d₂)
    @test nelms(d) == 110

    d₁ = PointSet(rand(2,3))
    d₂ = PointSet(rand(2,2))
    s₁ = georef((a=[1,2,3],b=[4,5,6]), d₁)
    s₂ = georef((a=[7.,8.],c=["foo","bar"]), d₂)
    s = vcat(s₁, s₂)
    @test nelms(s) == 5
    @test isequal(s[:a], [1.,2.,3.,7.,8.])
    @test isequal(s[:b], [4,5,6,missing,missing])
    @test isequal(s[:c], [missing,missing,missing,"foo","bar"])

    coords = rand(2,3)
    d₁ = georef((a=[1,2,3],), coords)
    d₂ = georef((b=[4.,5.,6.],), coords)
    d = hcat(d₁, d₂)
    s = Tables.schema(values(d))
    @test s.names == (:a, :b)
    @test s.types == (Int, Float64)
    @test d[:a] == [1,2,3]
    @test d[:b] == [4.,5.,6.]
  end

  @testset "unique" begin
    X = [i*j for i in 1:2, j in 1:1_000_000]
    z = rand(1_000_000)
    d = georef((z=[z;z],), [X X])
    u = uniquecoords(d)
    U = coordinates(u)
    @test nelms(u) == 1_000_000
    @test Set(eachcol(U)) == Set(eachcol(X))

    X = rand(3,100)
    z = rand(100)
    n = [string(i) for i in 1:100]
    Xd = hcat(X, X[:,1:10])
    zd = vcat(z, z[1:10])
    nd = vcat(n, n[1:10])
    sdata = georef(DataFrame(z=zd, n=nd), PointSet(Xd))
    ndata = uniquecoords(sdata)
    @test nelms(ndata) == 100
  end

  @testset "inside" begin
    # point set + rectangle
    𝒫 = PointSet([0. 2. 5. 7. 10.; 0. 3. 5. 6. 11.])
    𝒮 = georef((z=[1,2,3,4,5],), 𝒫)
    R1 = Rectangle((0.,0.), (5.,5.))
    R2 = Rectangle((5.,5.), (10.,10.))
    I = inside(𝒫, R1)
    @test coordinates(I) == [0. 2. 5.; 0. 3. 5.]
    I = inside(𝒫, R2)
    @test coordinates(I) == [5. 7.; 5. 6.]
    I = inside(𝒮, R1)
    I[:z] == [1,2,3]
    I = inside(𝒮, R2)
    I[:z] == [3,4]

    # regular grid + rectangle
    𝒢 = RegularGrid(3,3)
    𝒮 = georef((z=1:9,), 𝒢)
    R1 = Rectangle((0.,0.),(1.,1.))
    R2 = Rectangle((1.,1.),(2.,2.))
    R3 = Rectangle((0.,0.),(2.,2.))
    I = inside(𝒢, R1)
    @test I isa RegularGrid
    @test origin(I) == [0.,0.]
    @test spacing(I) == [1.,1.]
    @test size(I) == (2,2)
    I = inside(𝒢, R2)
    @test I isa RegularGrid
    @test origin(I) == [1.,1.]
    @test spacing(I) == [1.,1.]
    @test size(I) == (2,2)
    I = inside(𝒢, R3)
    @test I isa RegularGrid
    @test origin(I) == [0.,0.]
    @test spacing(I) == [1.,1.]
    @test size(I) == (3,3)
    for R in [R1,R2,R3]
      Ig = inside(𝒢, R)
      Is = inside(𝒮, R)
      Ds = domain(Is)
      @test Ds isa RegularGrid
      @test coordinates(Ds) == coordinates(Ig)
    end
  end

  @testset "split" begin
    d = RegularGrid(10,10)
    l, r = split(d, 0.5)
    @test nelms(l) == 50
    @test nelms(r) == 50
    l, r = split(d, 0.5, (1.,0.))
    @test nelms(l) == 50
    @test nelms(r) == 50
    cl = mean(coordinates(l), dims=2)
    cr = mean(coordinates(r), dims=2)
    @test cl[1] < cr[1]
    @test cl[2] == cr[2]
    l, r = split(d, 0.5, (0.,1.))
    @test nelms(l) == 50
    @test nelms(r) == 50
    cl = mean(coordinates(l), dims=2)
    cr = mean(coordinates(r), dims=2)
    @test cl[1] == cr[1]
    @test cl[2] < cr[2]
  end

  @testset "groupby" begin
    d = georef((z=[1,2,3],x=[4,5,6]), rand(2,3))
    g = groupby(d, :z)
    @test all(nelms.(g) .== 1)
    rows = [[1 4], [2 5], [3 6]]
    for i in 1:3
      @test Tables.matrix(values(g[i])) ∈ rows
    end
  end

  @testset "boundbox" begin
    d = RegularGrid((10,10), (1.,1.), (1.,1.))
    @test extrema(boundbox(d)) == ([1.,1.], [10.,10.])

    r = boundbox(RegularGrid(100,200))
    @test r == Rectangle((0.,0.), (99.,199.))

    r = boundbox(PointSet([0. 1. 2.; 0. 2. 1.]))
    @test r == Rectangle((0.,0.), (2.,2.))

    r = boundbox(PointSet([1. 2.; 2. 1.]))
    @test r == Rectangle((1.,1.), (2.,2.))
  end

  @testset "sample" begin
    d = georef((z=rand(10,10),))
    s = sample(d, 50)
    @test nelms(s) == 50
    s = sample(d, 50, rand([1,2], 100))
    @test nelms(s) == 50
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
    @test nelms(𝒫ₐ) == 2
    @test nelms(𝒫ᵦ) == 2
    @test nelms(𝒫ₐᵦ) == 1
    @test 𝒫ₐ[:a] == [2,3]
    @test 𝒫ₐ[:b] == [2,1]
    @test 𝒫ᵦ[:a] == [1,2]
    @test 𝒫ᵦ[:b] == [3,2]
    @test 𝒫ₐᵦ[:a] == [2]
    @test 𝒫ₐᵦ[:b] == [2]
  end

  @testset "slice" begin
    d = RegularGrid((10,10), (1.,1.), (1.,1.))
    s = slice(d, 0.:5., 0.:5.)
    @test s isa RegularGrid
    @test extrema(coordinates(s)) == (1.,5.)
    s = slice(d, 5.:20.5, 6.:21.0)
    @test coordinates(s, 1) == [5.,6.]
    @test coordinates(s, nelms(s)) == [10.,10.]

    d = RegularGrid(10,10,10)
    s = slice(d, 5.5:10.0, 2.3:4.2, -1.2:2.0)
    @test s isa RegularGrid
    @test origin(s) == [6.,3.,0.]
    @test spacing(s) == [1.,1.,1.]
    @test size(s) == (4,1,2)

    d = PointSet([1. 5. 7.; 2. 3. 6.])
    s = slice(d, 2.:6., 2.:6.)
    @test nelms(s) == 1
    @test coordinates(s, 1) == [5.,3.]
  end
end
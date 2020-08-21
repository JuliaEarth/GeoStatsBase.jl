@testset "Geometric operations" begin
  @testset "disjoint union" begin
    d₁ = RegularGrid(10,10)
    d₂ = PointSet(rand(2,10))
    d = d₁ ⊔ d₂
    @test npoints(d) == 110

    d₁ = PointSet(rand(2,3))
    d₂ = PointSet(rand(2,2))
    s₁ = georef((a=[1,2,3],b=[4,5,6]), d₁)
    s₂ = georef((a=[7.,8.],c=["foo","bar"]), d₂)
    s = s₁ ⊔ s₂
    @test npoints(s) == 5
    @test isequal(s[:a], [1.,2.,3.,7.,8.])
    @test isequal(s[:b], [4,5,6,missing,missing])
    @test isequal(s[:c], [missing,missing,missing,"foo","bar"])
  end

  @testset "uniquecoords" begin
    X = [i*j for i in 1:2, j in 1:1_000_000]
    z = rand(1_000_000)
    d = georef((z=[z;z],), [X X])
    u = uniquecoords(d)
    U = coordinates(u)
    @test npoints(u) == 1_000_000
    @test Set(eachcol(U)) == Set(eachcol(X))

    X = rand(3,100)
    z = rand(100)
    n = [string(i) for i in 1:100]
    Xd = hcat(X, X[:,1:10])
    zd = vcat(z, z[1:10])
    nd = vcat(n, n[1:10])
    sdata = georef(DataFrame(z=zd, n=nd), PointSet(Xd))
    ndata = uniquecoords(sdata)
    @test npoints(ndata) == 100
  end

  @testset "inside" begin
    # point set + rectangle
    𝒫 = PointSet([0. 2. 5. 7. 10.; 0. 3. 5. 6. 11.])
    𝒮 = georef((z=[1,2,3,4,5],), 𝒫)
    R1 = Rectangle((0.,0.), (5.,5.))
    R2 = Rectangle((5.,5.), (5.,5.))
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
    R2 = Rectangle((1.,1.),(1.,1.))
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
end
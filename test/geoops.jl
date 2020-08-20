@testset "Geometric operations" begin
  @testset "Inside" begin
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
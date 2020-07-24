@testset "Set operations" begin
  @testset "Disjoint union" begin
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
end

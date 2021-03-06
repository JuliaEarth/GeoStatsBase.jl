@testset "Partitioning" begin
  setify(lists) = Set(Set.(lists))

  @testset "SLIC" begin
    𝒮 = georef((z=[ones(10,10) 2ones(10,10); 3ones(10,10) 4ones(10,10)],))
    p = partition(𝒮, SLIC(4, 1.0))
    @test length(p) == 4
    @test all(nelements.(p) .== 100)
    p1, p2, p3, p4 = p
    @test mean(coordinates(centroid(p1, ind)) for ind in 1:nelements(p1)) == [5.0,5.0]
    @test mean(coordinates(centroid(p2, ind)) for ind in 1:nelements(p2)) == [15.0,5.0]
    @test mean(coordinates(centroid(p3, ind)) for ind in 1:nelements(p3)) == [5.0,15.0]
    @test mean(coordinates(centroid(p4, ind)) for ind in 1:nelements(p4)) == [15.0,15.0]

    𝒮 = georef((z=[√(i^2+j^2) for i in 1:100, j in 1:100],))
    p = partition(𝒮, SLIC(50, 1.0))
    @test length(p) == 49

    if visualtests
      @test_reference "data/slic.png" plot(p)
    end
  end
end

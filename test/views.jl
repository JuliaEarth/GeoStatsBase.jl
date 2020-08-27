@testset "Views" begin
  @testset "Domain" begin
    d = RegularGrid(10, 10)
    X = coordinates(d)
    v = view(d, 1:10)
    @test nelms(v) == 10
    @test coordinates(v) == X[:,1:10]
    @test collect(v) isa PointSet

    @test sprint(show, v) == "10 SpatialDomainView{Float64,2}"
    @test sprint(show, MIME"text/plain"(), v) == "10 SpatialDomainView{Float64,2}\n 0.0  1.0  2.0  3.0  4.0  5.0  6.0  7.0  8.0  9.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0"
  end

  @testset "Data" begin
    d = georef((z=rand(100), w=rand(100)))
    T = values(d)
    X = coordinates(d)
    v = view(d, 1:10)
    @test nelms(v) == 10
    @test coordinates(v) == X[:,1:10]
    @test collect(v) isa SpatialData

    @test sprint(show, v) == "10 SpatialDataView{Float64,1}"
    @test sprint(show, MIME"text/plain"(), v) == "10 SpatialDomainView{Float64,1}\n  variables\n    └─w (Float64)\n    └─z (Float64)" 

    d = georef((z=rand(100), w=rand(100)))
    v1 = view(d, shuffle(1:100))
    c1 = collect(v1)
    v2 = view(v1, [:z])
    c2 = view(c1, [:z])
    @test values(v2) == values(c2)
  end
end
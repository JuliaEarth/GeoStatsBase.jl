@testset "Filtering" begin
  @testset "UniqueCoordsFilter" begin
    X = rand(3,100)
    z = rand(100)
    n = [string(i) for i in 1:100]
    Xd = hcat(X, X[:,1:10])
    zd = vcat(z, z[1:10])
    nd = vcat(n, n[1:10])
    sdata = PointSetData(OrderedDict([:z=>zd, :n=>nd]), Xd)
    ndata = filter(sdata, UniqueCoordsFilter())
    @test npoints(ndata) == 100
  end
end

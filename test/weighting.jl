@testset "Weighting" begin
  @testset "BlockWeighter" begin
    sdomain = RegularGrid{Float64}(100,100)
    sdata = RegularGridData{Float64}(OrderedDict(:z=>rand(100,100)))
    for d in [sdomain, sdata]
      w = weight(d, BlockWeighter(10,10))
      @test length(unique(w)) == 1
      @test w[1] == 1 / 100
    end
  end

  @testset "DensityRatioWeighter" begin
    n = 1000; Random.seed!(123)

    r1 = Normal(0, 2)
    r2 = MixtureModel([Normal(-2,1), Normal(2,2)], [0.2, 0.8])

    z1 = sort(rand(r1, n))
    z2 = sort(rand(r2, n))

    d1 = PointSetData(OrderedDict(:z => z1), reshape(1:n,1,:))
    d2 = PointSetData(OrderedDict(:z => z2), reshape(1:n,1,:))

    w = weight(d1, DensityRatioWeighter(d2))

    if visualtests
      @plottest begin
        gr(size=(800,400))
        plot( z1, pdf.(r1, z1), label="source")
        plot!(z1, pdf.(r2, z1), label="target")
        plot!(z1, w .* pdf.(r1, z1), label="approx")
      end joinpath(datadir,"DensityRatioWeighter.png") !istravis
    end
  end
end

@testset "Weighting" begin
  @testset "BlockWeighter" begin
    # TODO
  end

  @testset "DensityRatioWeighter" begin
    n = 1000; Random.seed!(123)

    r1 = Normal(0, 2)
    r2 = MixtureModel([Normal(-2,1), Normal(2,2)], [0.2, 0.8])

    z1 = sort(rand(r1, n))
    z2 = sort(rand(r2, n))

    d1 = PointSetData(Dict(:z => z1), reshape(1:n,1,:))
    d2 = PointSetData(Dict(:z => z2), reshape(1:n,1,:))

    weighter = DensityRatioWeighter(d2, KLIEP())
    w = weight(d1, weighter)

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

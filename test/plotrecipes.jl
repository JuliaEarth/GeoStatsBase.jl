@testset "Plotting" begin
  Random.seed!(123)
  z₁ = randn(10000)
  z₂ = z₁ + randn(10000)
  d = georef(DataFrame(z₁=z₁,z₂=z₂), RegularGrid(100,100))

  @testset "DistPlot1D" begin
    if visualtests
      @plottest distplot1d(d,:z₁) joinpath(datadir,"distplot1D.png") !isCI
    end
  end

  @testset "DistPlot2D" begin
    if visualtests
      @plottest distplot2d(d,:z₁,:z₂) joinpath(datadir,"distplot2D.png") !isCI
    end
  end

  @testset "CornerPlot" begin
    if visualtests
      @plottest cornerplot(d) joinpath(datadir,"cornerplot.png") !isCI
    end
  end

  @testset "HScatter" begin
    if visualtests
      @plottest begin
        sdata = readgeotable(joinpath(datadir,"samples2D.tsv"), coordnames=(:x,:y))
        p0 = hscatter(sdata, :value, lag=0)
        p1 = hscatter(sdata, :value, lag=1)
        p2 = hscatter(sdata, :value, lag=2)
        p3 = hscatter(sdata, :value, lag=3)
        plot(p0, p1, p2, p3, layout=(2,2), size=(600,600))
      end joinpath(datadir,"hscatter.png") !isCI
    end
  end
end

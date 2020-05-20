@testset "Data" begin
  @testset "Basics" begin
    d = PointSetData(OrderedDict(:z=>rand(3)), rand(2,3))
    v = view(d, [1,3])

    d[1,:z] = 1.
    d[2,:z] = 2.
    v[2,:z] = 3.
    @test d[:z] == [1.,2.,3.]
    @test v[:z] == [1.,3.]
    v[:z] = [3.,1.]
    @test d[:z] == [3.,2.,1.]
    @test v[:z] == [3.,1.]
  end

  @testset "CurveData" begin
    c = CurveData(OrderedDict(:z => 1:10), [j for i in 1:3, j in 1:10])
    @test coordnames(c) == (:x1, :x2, :x3)
    @test variables(c) == OrderedDict(:z => Int)
    @test npoints(c) == 10

    if visualtests
      gr(size=(800,800))
      c1 = CurveData(OrderedDict(:z => 1:10), [j for i in 1:1, j in 1:10])
      c2 = CurveData(OrderedDict(:z => 1:10), [j for i in 1:2, j in 1:10])
      c3 = CurveData(OrderedDict(:z => 1:10), [j for i in 1:3, j in 1:10])
      @plottest plot(c1,ms=4) joinpath(datadir,"CurveData1D.png") !istravis
      @plottest plot(c2,ms=4) joinpath(datadir,"CurveData2D.png") !istravis
      @plottest plot(c3,ms=4) joinpath(datadir,"CurveData3D.png") !istravis
    end
  end

  @testset "GeoDataFrame" begin
    # basic checks
    data3D   = readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t')
    X, z = valid(data3D, :value)
    @test coordnames(data3D) == (:x, :y, :z)
    @test variables(data3D) == OrderedDict(:value => Float64)
    @test npoints(data3D) == 100
    @test size(X) == (3, 100)
    @test length(z) == 100

    # missing data and NaN
    missdata = readgeotable(joinpath(datadir,"missing.tsv"), delim='\t', coordnames=[:x,:y])
    X, z = valid(missdata, :value)
    @test size(X) == (2,1)
    @test length(z) == 1

    # show methods
    rawdata = DataFrame(x=[1,2,3],y=[4,5,6])
    sdata = GeoDataFrame(rawdata, [:x,:y])
    @test sprint(show, sdata) == "3×2 GeoDataFrame (x and y)"
    @test sprint(show, MIME"text/plain"(), sdata) == "3×2 GeoDataFrame (x and y)\n\n│ Row │ x     │ y     │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 1     │ 4     │\n│ 2   │ 2     │ 5     │\n│ 3   │ 3     │ 6     │"
    @test sprint(show, MIME"text/html"(), sdata) == "3×2 GeoDataFrame (x and y)\n<table class=\"data-frame\"><thead><tr><th></th><th>x</th><th>y</th></tr><tr><th></th><th>Int64</th><th>Int64</th></tr></thead><tbody><tr><th>1</th><td>1</td><td>4</td></tr><tr><th>2</th><td>2</td><td>5</td></tr><tr><th>3</th><td>3</td><td>6</td></tr></tbody></table>"

    if visualtests
      gr(size=(800,800))
      df = DataFrame(x=[25.,50.,75.],y=[25.,75.,50.],z=[1.,0.,1.])
      sdata = GeoDataFrame(df, [:x,:y])
      @plottest plot(sdata) joinpath(datadir,"GeoDataFrame.png") !istravis
    end
  end

  @testset "PointSetData" begin
    # basic checks
    data3D = readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t')
    X, z = valid(data3D, :value)
    ps = PointSetData(OrderedDict(:value => z), X)
    X, z = valid(ps, :value)
    @test coordnames(ps) == (:x1, :x2, :x3)
    @test variables(ps) == OrderedDict(:value => Float64)
    @test npoints(ps) == 100
    @test size(X,2) == 100
    @test length(z) == 100

    # show methods
    ps = PointSetData(OrderedDict(:value => [1,2,3]), [1. 0. 1.; 0. 1. 1.])
    @test sprint(show, ps) == "3 PointSetData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), ps) == "3 PointSetData{Float64,2}\n  variables\n    └─value (Int64)"

    if visualtests
      gr(size=(800,800))
      sdata = PointSetData(OrderedDict(:z => [1.,0.,1.]), [25. 50. 75.; 25. 75. 50.])
      @plottest plot(sdata) joinpath(datadir,"PointSetData.png") !istravis
    end
  end

  @testset "RegularGridData" begin
    # basic checks
    g = RegularGridData{Float64}(OrderedDict(:value => rand(100,100)))
    X, z = valid(g, :value)
    @test size(g) == (100, 100)
    @test origin(g) == [0., 0.]
    @test spacing(g) == [1., 1.]
    @test coordnames(g) == (:x1, :x2)
    @test variables(g) == OrderedDict(:value => Float64)
    @test npoints(g) == 10000
    @test size(X) == (2, 10000)
    @test length(z) == 10000

    # show methods
    g = RegularGridData(OrderedDict(:z => [1 2; 3 4]), (0.,0.), (1.,1.))
    @test sprint(show, g) == "2×2 RegularGridData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), g) == "2×2 RegularGridData{Float64,2}\n  origin:  (0.0, 0.0)\n  spacing: (1.0, 1.0)\n  variables\n    └─z (Int64)"

    if visualtests
      gr(size=(800,800))
      sdata = RegularGridData(OrderedDict(:z => [1 2; 3 4]), (0.,0.), (0.1,0.1))
      @plottest plot(sdata) joinpath(datadir,"RegularGridData.png") !istravis
    end
  end

  @testset "StructuredGridData" begin
    X = readdlm(joinpath(datadir,"HurricaneX.dat"))
    Y = readdlm(joinpath(datadir,"HurricaneY.dat"))
    P = readdlm(joinpath(datadir,"HurricaneP.dat"))
    g = StructuredGridData(OrderedDict(:precipitation => P), X, Y)

    # basic checks
    @test size(g) == (221, 366)
    @test coordnames(g) == (:x1, :x2)
    @test variables(g) == OrderedDict(:precipitation => Float64)
    @test npoints(g) == 221*366

    # missing values
    X, z = valid(g, :precipitation)
    @test size(X) == (2, 64416)
    @test length(z) == 64416

    # show methods
    @test sprint(show, g) == "221×366 StructuredGridData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), g) == "221×366 StructuredGridData{Float64,2}\n  variables\n    └─precipitation (Float64)"

    if visualtests
      gr(size=(800,800))
      # @plottest plot(g,ms=0.1) joinpath(datadir,"StructuredGridData.png") !istravis
    end
  end
end

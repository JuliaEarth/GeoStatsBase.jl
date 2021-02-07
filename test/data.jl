@testset "Data" begin
  @testset "Basics" begin
    # underlying table
    z = rand(10,10)
    d = georef((z=z,))
    t = values(d)
    @test size(t) == (100,1)
    @test propertynames(t) == [:z]
    @test asarray(d, :z) == z

    # data equality
    d1 = georef((z=[1,2,3],))
    d2 = georef((z=[1,2,3],))
    d3 = georef((z=[4,5,6],))
    @test d1 == d2
    @test d1 != d3
    @test d2 != d3

    # bidimensional views
    d = georef((z=rand(10,10),))
    v = view(d, 1:3, [:z])
    td = DataFrame(values(d))
    tv = DataFrame(values(v))
    @test nelms(v) == 3
    @test td[1:3,:z] == tv[:,:z]

    # tables API
    x, y, z = rand(100), rand(100), rand(100)
    t = DataFrame(x=x,y=y,z=z)
    d = georef((x=x,y=y,z=z))
    @test asarray(d, :x) == x
    @test asarray(d, :y) == y
    @test asarray(d, :z) == z
    v = view(d, 1:3)
    @test asarray(v, :x) == x[1:3]
    @test asarray(v, :y) == y[1:3]
    @test asarray(v, :z) == z[1:3]
    @test Tables.istable(d) == true
    @test Tables.istable(v) == true
    @test Tables.rowaccess(d) == Tables.rowaccess(t)
    @test Tables.columnaccess(d) == Tables.columnaccess(t)
    @test Tables.rows(d) == Tables.rows(t)
    @test Tables.columns(d) == Tables.columns(t)
    rv = DataFrame(Tables.rows(v))
    rt = DataFrame(Tables.rows(t[1:3,:]))
    cv = DataFrame(Tables.columns(v))
    ct = DataFrame(Tables.columns(t[1:3,:]))
    @test rv == rt
    @test cv == ct

    # kwargs
    d = georef((z=rand(10,10),))
    v = view(d, 1:3)
    s = 3
    @test EmpiricalHistogram(d, v, s; bins=10) == fit(DummyEstimator, d[v], weight(d, w); bins=10)
  end

  @testset "GeoTable" begin
    # basic checks
    D = readgeotable(joinpath(datadir,"data3D.tsv"))
    @test variables(D) == (Variable(:value, Float64),)
    @test nelms(D) == 100

    # show methods
    df = DataFrame(x=[1,2,3],y=[4,5,6],z=[1.,2.,3.])
    sdata = georef(df, (:x,:y))
    @test sprint(show, sdata) == "3 SpatialData{Int64,2}"
    @test sprint(show, MIME"text/plain"(), sdata) == "3 PointSet{Int64,2}\n  variables\n    └─z (Float64)"

    if visualtests
      df = DataFrame(x=[25.,50.,75.],y=[25.,75.,50.],z=[1.,0.,1.])
      sdata = georef(df, (:x,:y))
      @plottest plot(sdata) joinpath(datadir,"geodf.png") !isCI
    end
  end

  @testset "PointSet" begin
    # basic checks
    ps = readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t')
    @test variables(ps) == (Variable(:value, Float64),)
    @test nelms(ps) == 100

    # show methods
    ps = georef((z=[1,2,3],), [1. 0. 1.; 0. 1. 1.])
    @test sprint(show, ps) == "3 SpatialData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), ps) == "3 PointSet{Float64,2}\n  variables\n    └─z (Int64)"

    if visualtests
      sdata = georef((z=[1.,0.,1.],), [25. 50. 75.; 25. 75. 50.])
      @plottest plot(sdata) joinpath(datadir,"pset-data.png") !isCI
    end
  end

  @testset "RegularGrid" begin
    # basic checks
    Z = rand(100,100)
    g = georef((Z=Z,))
    @test variables(g) == (Variable(:Z, Float64),)
    @test nelms(g) == 10000
    @test asarray(g, :Z) == Z

    # show methods
    g = georef((z=[1,2,3,4],), RegularGrid(2,2))
    @test sprint(show, g) == "4 SpatialData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), g) == "2×2 RegularGrid{Float64,2}\n  variables\n    └─z (Int64)"

    if visualtests
      sdata = georef((z=[1 2; 3 4],))
      @plottest plot(sdata) joinpath(datadir,"grid2D-data1.png") !isCI
      sdata = georef((z=[1 2; 3 4],), (-10.,-10.), (10.,10.))
      @plottest plot(sdata) joinpath(datadir,"grid2D-data2.png") !isCI
    end
  end

  @testset "StructuredGrid" begin
    X = readdlm(joinpath(datadir,"HurricaneX.dat"))
    Y = readdlm(joinpath(datadir,"HurricaneY.dat"))
    P = readdlm(joinpath(datadir,"HurricaneP.dat"))
    g = georef((P=P,), StructuredGrid(X, Y))

    # basic checks
    @test variables(g) == (Variable(:P, Float64),)
    @test nelms(g) == 221*366

    # show methods
    @test sprint(show, g) == "80886 SpatialData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), g) == "221×366 StructuredGrid{Float64,2}\n  variables\n    └─P (Float64)"

    if visualtests
      # TODO
    end
  end
end

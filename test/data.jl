@testset "Data" begin
  @testset "Basics" begin
    # views and mutation
    d = georef((z=rand(3),), rand(2,3))
    v = view(d, [1,3])
    d[1,:z] = 1.
    d[2,:z] = 2.
    v[2,:z] = 3.
    @test d[:z] == [1.,2.,3.]
    @test v[:z] == [1.,3.]
    v[:z] = [3.,1.]
    @test d[:z] == [3.,2.,1.]
    @test v[:z] == [3.,1.]

    # underlying table
    d = georef((z=rand(10,10),))
    t = values(d)
    @test size(t) == (100,1)
    @test propertynames(t) == [:z]

    # bidimensional views
    d = georef((z=rand(10,10),))
    v = view(d, 1:3, [:z])
    td = values(d)
    tv = values(v)
    @test npoints(v) == 3
    @test td[1:3,:z] == tv[:,:z]

    # indexable API
    d = georef((x=[1,2,3],y=[4,5,6]), rand(2,3))
    v = view(d, 2:3)
    @test collect(d[1]) == [1,4]
    @test collect(d[2]) == [2,5]
    @test collect(d[3]) == [3,6]
    @test collect(v[1]) == collect(d[2])
    @test collect(v[2]) == collect(d[3])
    @test firstindex(d) == 1
    @test firstindex(v) == 1
    @test lastindex(d) == 3
    @test lastindex(v) == 2

    # tables API
    x, y, z = rand(100), rand(100), rand(100)
    t = DataFrame(x=x,y=y,z=z)
    d = georef((x=x,y=y,z=z))
    @test Tables.istable(d) == true
    @test Tables.rowaccess(d) == Tables.rowaccess(t)
    @test Tables.columnaccess(d) == Tables.columnaccess(t)
    @test Tables.rows(d) == Tables.rows(t)
    @test Tables.columns(d) == Tables.columns(t)
  end

  @testset "Curve" begin
    c = georef((z=1:10,), Curve([j for i in 1:3, j in 1:10]))
    @test collect(variables(c)) == [:z => Int]
    @test npoints(c) == 10

    if visualtests
      c1 = georef((z=1:10,), Curve([j for i in 1:1, j in 1:10]))
      c2 = georef((z=1:10,), Curve([j for i in 1:2, j in 1:10]))
      c3 = georef((z=1:10,), Curve([j for i in 1:3, j in 1:10]))
      @plottest plot(c1,ms=4) joinpath(datadir,"curve-data1D.png") !istravis
      @plottest plot(c2,ms=4) joinpath(datadir,"curve-data2D.png") !istravis
      @plottest plot(c3,ms=4) joinpath(datadir,"curve-data3D.png") !istravis
    end
  end

  @testset "GeoTable" begin
    # basic checks
    data3D = readgeotable(joinpath(datadir,"data3D.tsv"))
    X, z = valid(data3D, :value)
    @test collect(variables(data3D)) == [:value => Float64]
    @test npoints(data3D) == 100
    @test size(X) == (3, 100)
    @test length(z) == 100

    # missing data and NaN
    missdata = readgeotable(joinpath(datadir,"missing.tsv"), coordnames=(:x,:y))
    X, z = valid(missdata, :value)
    @test size(X) == (2,1)
    @test length(z) == 1

    # show methods
    df = DataFrame(x=[1,2,3],y=[4,5,6],z=[1.,2.,3.])
    sdata = georef(df, (:x,:y))
    @test sprint(show, sdata) == "3 SpatialData{Int64,2}"
    @test sprint(show, MIME"text/plain"(), sdata) == "3 PointSet{Int64,2}\n  variables\n    └─z (Float64)"

    if visualtests
      df = DataFrame(x=[25.,50.,75.],y=[25.,75.,50.],z=[1.,0.,1.])
      sdata = georef(df, (:x,:y))
      @plottest plot(sdata) joinpath(datadir,"geodf.png") !istravis
    end
  end

  @testset "PointSet" begin
    # basic checks
    data3D = readgeotable(joinpath(datadir,"data3D.tsv"), delim='\t')
    X, z = valid(data3D, :value)
    ps = georef((value=z,), X)
    X, z = valid(ps, :value)
    @test collect(variables(ps)) == [:value => Float64]
    @test npoints(ps) == 100
    @test size(X,2) == 100
    @test length(z) == 100

    # show methods
    ps = georef((z=[1,2,3],), [1. 0. 1.; 0. 1. 1.])
    @test sprint(show, ps) == "3 SpatialData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), ps) == "3 PointSet{Float64,2}\n  variables\n    └─z (Int64)"

    if visualtests
      sdata = georef((z=[1.,0.,1.],), [25. 50. 75.; 25. 75. 50.])
      @plottest plot(sdata) joinpath(datadir,"pset-data.png") !istravis
    end
  end

  @testset "RegularGrid" begin
    # basic checks
    g = georef((value=rand(100,100),))
    X, z = valid(g, :value)
    @test collect(variables(g)) == [:value => Float64]
    @test npoints(g) == 10000
    @test size(X) == (2, 10000)
    @test length(z) == 10000

    # show methods
    g = georef((z=[1,2,3,4],), RegularGrid(2,2))
    @test sprint(show, g) == "4 SpatialData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), g) == "2×2 RegularGrid{Float64,2}\n  variables\n    └─z (Int64)"

    if visualtests
      sdata = georef((z=[1 2; 3 4],))
      @plottest plot(sdata) joinpath(datadir,"grid2D-data1.png") !istravis
      sdata = georef((z=[1 2; 3 4],), (-10.,-10.), (10.,10.))
      @plottest plot(sdata) joinpath(datadir,"grid2D-data2.png") !istravis
    end
  end

  @testset "StructuredGrid" begin
    X = readdlm(joinpath(datadir,"HurricaneX.dat"))
    Y = readdlm(joinpath(datadir,"HurricaneY.dat"))
    P = readdlm(joinpath(datadir,"HurricaneP.dat"))
    g = georef((precip=P,), StructuredGrid(X, Y))

    # basic checks
    @test collect(variables(g)) == [:precip => Float64]
    @test npoints(g) == 221*366

    # missing values
    X, z = valid(g, :precip)
    @test size(X) == (2, 64416)
    @test length(z) == 64416

    # show methods
    @test sprint(show, g) == "80886 SpatialData{Float64,2}"
    @test sprint(show, MIME"text/plain"(), g) == "221×366 StructuredGrid{Float64,2}\n  variables\n    └─precip (Float64)"

    if visualtests
      # TODO
    end
  end
end

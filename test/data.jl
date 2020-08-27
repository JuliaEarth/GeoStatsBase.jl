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
    @test nelms(v) == 3
    @test td[1:3,:z] == tv[:,:z]

    # tables API
    x, y, z = rand(100), rand(100), rand(100)
    t = DataFrame(x=x,y=y,z=z)
    d = georef((x=x,y=y,z=z))
    v = view(d, 1:3)
    @test Tables.istable(d) == true
    @test Tables.rowaccess(d) == Tables.rowaccess(t)
    @test Tables.columnaccess(d) == Tables.columnaccess(t)
    @test Tables.rows(d) == Tables.rows(t)
    @test Tables.columns(d) == Tables.columns(t)
    @test Tables.istable(v) == true
    @test Tables.rowaccess(v) == Tables.rowaccess(d)
    @test Tables.columnaccess(v) == Tables.columnaccess(d)
    @test Tables.rows(v) == Tables.rows(t[1:3,:])
    @test Tables.columns(v) == Tables.columns(t[1:3,:])
  end

  @testset "Curve" begin
    c = georef((z=1:10,), Curve([j for i in 1:3, j in 1:10]))
    @test variables(c) == (Variable(:z, Int),)
    @test nelms(c) == 10

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
      @plottest plot(sdata) joinpath(datadir,"geodf.png") !istravis
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
      @plottest plot(sdata) joinpath(datadir,"pset-data.png") !istravis
    end
  end

  @testset "RegularGrid" begin
    # basic checks
    g = georef((Z=rand(100,100),))
    @test variables(g) == (Variable(:Z, Float64),)
    @test nelms(g) == 10000

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

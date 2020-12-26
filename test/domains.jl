@testset "Domains" begin
  @testset "PointSet" begin
    # different ways to build a PointSet
    ps1 = PointSet([1. 0.; 0. 1.])            # as matrix
    ps2 = PointSet([(1.0, 0.0), (0.0, 1.0)])  # as vector of tuples
    @test ps1.coords == ps2.coords

    ps1 = PointSet([1. 0.; 0. 1.])
    ps2 = PointSet([1. 0.; 0. 1.])
    ps3 = PointSet([0. 0.; 0. 1.])
    @test ps1 == ps2
    @test ps1 != ps3
    @test ps2 != ps3

    # building a PointSet of tuples with different lengths should fail
    @test_throws MethodError PointSet([(1.0, 0.0), (0.0, 1.0 , 4.0)])

    # more tests 
    ps = PointSet([1. 0.; 0. 1.])

    @test nelms(ps) == 2
    @test coordinates(ps, 1) == [1., 0.]
    @test coordinates(ps, 2) == [0., 1.]

    @test sprint(show, ps) == "2 PointSet{Float64,2}"
    @test sprint(show, MIME"text/plain"(), ps) == "2 PointSet{Float64,2}\n 1.0  0.0\n 0.0  1.0"

    if visualtests
      Random.seed!(2019)
      @plottest plot(PointSet(rand(1,10))) joinpath(datadir,"pset1D.png") !isCI
      @plottest plot(PointSet(rand(2,10))) joinpath(datadir,"pset2D.png") !isCI
      @plottest plot(PointSet(rand(3,10))) joinpath(datadir,"pset3D.png") !isCI
      @plottest plot(PointSet(rand(1,10)),1:10) joinpath(datadir,"pset1D-data.png") !isCI
      @plottest plot(PointSet(rand(2,10)),1:10) joinpath(datadir,"pset2D-data.png") !isCI
      @plottest plot(PointSet(rand(3,10)),1:10) joinpath(datadir,"pset3D-data.png") !isCI
    end
  end

  @testset "RegularGrid" begin
    grid = RegularGrid{Float32}(200,100)
    @test ncoords(grid) == 2
    @test coordtype(grid) == Float32
    @test size(grid) == (200,100)
    @test nelms(grid) == 200*100
    @test coordinates(grid, 1) == [0.,0.]
    @test origin(grid) == [0f0, 0f0]
    @test spacing(grid) == [1f0, 1f0]

    grid = RegularGrid((200,100,50), (0.,0.,0.), (1.,1.,1.))
    @test ncoords(grid) == 3
    @test coordtype(grid) == Float64
    @test size(grid) == (200,100,50)
    @test nelms(grid) == 200*100*50
    @test coordinates(grid, 1) == [0.,0.,0.]
    @test origin(grid) == [0.,0.,0.]
    @test spacing(grid) == [1.,1.,1.]

    grid = RegularGrid((-1.,-1.), (1.,1.), dims=(200,100))
    @test ncoords(grid) == 2
    @test coordtype(grid) == Float64
    @test size(grid) == (200,100)
    @test nelms(grid) == 200*100
    @test coordinates(grid, 1) == [-1.,-1.]
    @test coordinates(grid, 200*100) == [1.,1.]
    @test origin(grid) == [-1.,-1.]

    grid1 = RegularGrid(100,100)
    grid2 = RegularGrid(100,100)
    grid3 = RegularGrid(100,50)
    @test grid1 == grid2
    @test grid1 != grid3
    @test grid2 != grid3

    grid = RegularGrid(100,200)
    @test sprint(show, grid) == "100×200 RegularGrid{Float64,2}"
    @test sprint(show, MIME"text/plain"(), grid) == "100×200 RegularGrid{Float64,2}\n  origin:  (0.0, 0.0)\n  spacing: (1.0, 1.0)"

    if visualtests
      @plottest plot(RegularGrid(10)) joinpath(datadir,"grid1D.png") !isCI
      @plottest plot(RegularGrid(10,20)) joinpath(datadir,"grid2D.png") !isCI
      @plottest plot(RegularGrid(10,20,30)) joinpath(datadir,"grid3D.png") !isCI
      @plottest plot(RegularGrid(10),[1,2,3,4,5,5,4,3,2,1]) joinpath(datadir,"grid1D-data.png") !isCI
      @plottest plot(RegularGrid(10,10),1:100) joinpath(datadir,"grid2D-data.png") !isCI
      # @plottest plot(RegularGrid(10,10,10),collect(1:1.0:1000)) joinpath(datadir,"grid3D-data.png") !isCI
    end
  end

  @testset "StructuredGrid" begin
    nx, ny, nz = 20, 10, 10

    X = [1.,5.,6.,10.]
    g1 = StructuredGrid(X)
    @test nelms(g1) == 4
    @test coordinates(g1) == [1. 5. 6. 10.]

    @test sprint(show, g1) == "4 StructuredGrid{Float64,1}"
    @test sprint(show, MIME"text/plain"(), g1) == "4 StructuredGrid{Float64,1}\n 1.0  5.0  6.0  10.0"

    X  = [x for x in range(0,10,length=nx), j in 1:ny]
    Y  = sin.(X) .+ [0.5j for i in 1:nx, j in 1:ny]
    g2 = StructuredGrid(X, Y)
    @test nelms(g2) == nx*ny
    @test size(g2) == (nx, ny)
    @test size(coordinates(g2)) == (2, nx*ny)

    @test sprint(show, g2) == "20×10 StructuredGrid{Float64,2}"

    X = [x for x in range(0,10,length=nx), j in 1:ny, k in 1:nz]
    Y = sin.(X) .+ [0.5j for i in 1:nx, j in 1:ny, k in 1:nz]
    Z = [1.0(k-1) for i in 1:nx, j in 1:ny, k in 1:nz]
    g3 = StructuredGrid(X, Y, Z)
    @test nelms(g3) == nx*ny*nz
    @test size(g3) == (nx, ny, nz)
    @test size(coordinates(g3)) == (3, nx*ny*nz)

    @test g1 != g2
    @test g2 != g3
    @test g1 != g3

    @test sprint(show, g3) == "20×10×10 StructuredGrid{Float64,3}"

    if visualtests
      @plottest plot(g1) joinpath(datadir,"sgrid1D.png") !isCI
      @plottest plot(g2) joinpath(datadir,"sgrid2D.png") !isCI
      @plottest plot(g3,camera=(30,60)) joinpath(datadir,"sgrid3D.png") !isCI
      @plottest plot(g1,[1.,2.,2.,1]) joinpath(datadir,"sgrid1D-data.png") !isCI
      @plottest plot(g2,1:nx*ny) joinpath(datadir,"sgrid2D-data.png") !isCI
      @plottest plot(g3,1:nx*ny*nz) joinpath(datadir,"sgrid3D-data.png") !isCI
    end
  end
end

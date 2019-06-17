@testset "Partitions" begin
  setify(lists) = Set(Set.(lists))
  @testset "UniformPartitioner" begin
    grid = RegularGrid{Float64}(3,3)

    Random.seed!(123)
    p = partition(grid, UniformPartitioner(3, false))
    @test setify(subsets(p)) == setify([[1,2,3], [4,5,6], [7,8,9]])
    p = partition(grid, UniformPartitioner(3))
    @test setify(subsets(p)) == setify([[8,6,9], [4,1,7], [2,3,5]])

    grid = RegularGrid{Float64}(2,3)
    p = partition(grid, UniformPartitioner(3, false))
    @test setify(subsets(p)) == setify([[1,2], [3,4], [5,6]])
  end

  @testset "DirectionPartitioner" begin
    grid = RegularGrid{Float64}(3,3)

    # basic checks on small regular grid data
    p = partition(grid, DirectionPartitioner((1.,0.)))
    @test setify(subsets(p)) == setify([[1,2,3], [4,5,6], [7,8,9]])

    p = partition(grid, DirectionPartitioner((0.,1.)))
    @test setify(subsets(p)) == setify([[1,4,7], [2,5,8], [3,6,9]])

    p = partition(grid, DirectionPartitioner((1.,1.)))
    @test setify(subsets(p)) == setify([[1,5,9], [2,6], [3], [4,8], [7]])

    p = partition(grid, DirectionPartitioner((1.,-1.)))
    @test setify(subsets(p)) == setify([[1], [2,4], [3,5,7], [6,8], [9]])

    # opposite directions produce same partition
    dir1 = (rand(), rand()); dir2 = .-dir1
    p1 = partition(grid, DirectionPartitioner(dir1))
    p2 = partition(grid, DirectionPartitioner(dir2))
    @test setify(subsets(p1)) == setify(subsets(p2))

    # partition of arbitrarily large regular grid always
    # returns the "lines" and "columns" of the grid
    for n in [10,100,200]
      grid = RegularGrid{Float64}(n,n)

      p = partition(grid, DirectionPartitioner((1.,0.)))
      @test setify(subsets(p)) == setify([collect((i-1)*n+1:i*n) for i in 1:n])
      ns = [npoints(d) for d in p]
      @test all(ns .== n)

      p = partition(grid, DirectionPartitioner((0.,1.)))
      @test setify(subsets(p)) == setify([collect(i:n:n*n) for i in 1:n])
      ns = [npoints(d) for d in p]
      @test all(ns .== n)
    end
  end

  @testset "FractionPartitioner" begin
    # TODO
  end

  @testset "BlockPartitioner" begin
    # TODO
  end

  @testset "BallPartitioner" begin
    # TODO
  end

  @testset "PlanePartitioner" begin
    # TODO
  end

  @testset "FunctionPartitioner" begin
    # TODO
  end

  @testset "ProductPartitioner" begin
    # TODO
  end

  @testset "HierarchicalPartitioner" begin
    # TODO
  end
end

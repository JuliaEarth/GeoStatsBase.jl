@testset "Geometric operations" begin
  @testset "describe" begin
    table = (x=rand(10), y=rand(10), z=rand(10))
    sdata = georef(table, rand(2, 10))
    columns = [table.x, table.y, table.z]

    dtable = describe(sdata)
    @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == mean.(columns)
    @test dtable.minimum == minimum.(columns)
    @test dtable.median == median.(columns)
    @test dtable.maximum == maximum.(columns)
    @test dtable.nmissing == GeoStatsBase.nmissing.(columns)

    dtable = describe(sdata, funs=[mean, median, std])
    @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == mean.(columns)
    @test dtable.median == median.(columns)
    @test dtable.std == std.(columns)

    funs = [mean, median, std]
    columns = [table.y, table.z]
    colspecs = [["y", "z"], ("y", "z"), [:y, :z], (:y, :z), [2, 3], (2, 3), r"[yz]"]

    for colspec in colspecs
      dtable = describe(sdata, colspec)
      @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
      @test dtable.variable == [:y, :z]
      @test dtable.mean == mean.(columns)
      @test dtable.minimum == minimum.(columns)
      @test dtable.median == median.(columns)
      @test dtable.maximum == maximum.(columns)
      @test dtable.nmissing == GeoStatsBase.nmissing.(columns)
    end

    for colspec in colspecs
      dtable = describe(sdata, colspec; funs)
      @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
      @test dtable.variable == [:y, :z]
      @test dtable.mean == mean.(columns)
      @test dtable.median == median.(columns)
      @test dtable.std == std.(columns)
    end
  end

  @testset "integrate" begin
    grid = CartesianGrid(2, 2)
    mesh = simplexify(grid)
    table = (z=[1, 2, 3, 4, 5, 6, 7, 8, 9], w=[1, 1, 1, 2, 2, 2, 3, 3, 3])
    gdata = meshdata(grid, vtable=table)
    mdata = meshdata(mesh, vtable=table)
    ginte = integrate(gdata, :z, :w)
    minte = integrate(mdata, :z, :w)
    @test ginte.z == [3.0, 4.0, 6.0, 7.0]
    @test ginte.w == [1.5, 1.5, 2.5, 2.5]
    @test sum.(Iterators.partition(minte.z, 2)) == ginte.z
    @test sum.(Iterators.partition(minte.w, 2)) == ginte.w
  end

  @testset "@groupby" begin
    d = georef((z=[1, 2, 3], x=[4, 5, 6]), rand(2, 3))
    g = @groupby(d, :z)
    @test all(nitems.(g) .== 1)
    rows = [[1 4], [2 5], [3 6]]
    for i in 1:3
      @test Tables.matrix(values(g[i])) ∈ rows
    end

    z = vec([1 1 1; 2 2 2; 3 3 3])
    sdata = georef((z=z,), CartesianGrid(3, 3))
    p = @groupby(sdata, :z)
    @test indices(p) == [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

    # groupby with missing values
    z = vec([missing 1 1; 2 missing 2; 3 3 missing])
    sdata = georef((z=z,), CartesianGrid(3, 3))
    p = @groupby(sdata, :z)
    @test indices(p) == [[1, 5, 9], [2, 8], [3, 6], [4, 7]]

    # macro
    x = [1, 1, 1, 1, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, 4, 4]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    # args...
    # integers
    p = @groupby(sdata, 1)
    @test indices(p) == [[1, 2, 3, 4], [5, 6, 7, 8]]
    # symbols
    p = @groupby(sdata, :y)
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]
    # strings
    p = @groupby(sdata, "x", "y")
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    # vector...
    # integers
    p = @groupby(sdata, [1])
    @test indices(p) == [[1, 2, 3, 4], [5, 6, 7, 8]]
    # symbols
    p = @groupby(sdata, [:y])
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]
    # strings
    p = @groupby(sdata, ["x", "y"])
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    # tuple...
    # integers
    p = @groupby(sdata, (1,))
    @test indices(p) == [[1, 2, 3, 4], [5, 6, 7, 8]]
    # symbols
    p = @groupby(sdata, (:y,))
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]
    # strings
    p = @groupby(sdata, ("x", "y"))
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    # regex
    p = @groupby(sdata, r"[xy]")
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    # variable interpolation
    cols = (:x, :y)
    p = @groupby(sdata, cols)
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]
    p = @groupby(sdata, cols...)
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    c1, c2 = :x, :y
    p = @groupby(sdata, c1, c2)
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]
    p = @groupby(sdata, [c1, c2])
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]
    p = @groupby(sdata, (c1, c2))
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    # missing values
    x = [1, 1, missing, missing, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, missing, missing]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    p = @groupby(sdata, :x)
    @test indices(p) == [[1, 2], [3, 4], [5, 6, 7, 8]]
    p = @groupby(sdata, :x, :y)
    @test indices(p) == [[1, 2], [3, 4], [5, 6], [7, 8]]

    # isequal
    x = [0.0, 0, 0, -0.0, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, 4, 4]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    p = @groupby(sdata, :x)
    @test indices(p) == [[1, 2, 3], [4], [5, 6, 7, 8]]
    p = @groupby(sdata, :x, :y)
    @test indices(p) == [[1, 2], [3], [4], [5, 6], [7, 8]]
  end

  @testset "@transform" begin
    table = (x=rand(10), y=rand(10))
    sdata = georef(table, rand(2, 10))

    ndata = @transform(sdata, :z = :x - 2 * :y)
    @test ndata.z == sdata.x .- 2 .* sdata.y

    ndata = @transform(sdata, :z = :x - :y, :w = :x + :y)
    @test ndata.z == sdata.x .- sdata.y
    @test ndata.w == sdata.x .+ sdata.y

    ndata = @transform(sdata, :sinx = sin(:x), :cosy = cos(:y))
    @test ndata.sinx == sin.(sdata.x)
    @test ndata.cosy == cos.(sdata.y)

    # user defined functions & :geometry
    dist(point) = norm(coordinates(point))
    ndata = @transform(sdata, :dist_to_origin = dist(:geometry))
    @test ndata.dist_to_origin == dist.(domain(sdata))

    # replece :geometry column
    testfunc(point) = Point(coordinates(point) .+ 1)
    ndata = @transform(sdata, :geometry = testfunc(:geometry))
    @test domain(ndata) == GeometrySet(testfunc.(domain(sdata)))

    # unexported functions
    ndata = @transform(sdata, :logx = Base.log(:x), :expy = Base.exp(:y))
    @test ndata.logx == log.(sdata.x)
    @test ndata.expy == exp.(sdata.y)

    # column name interpolation
    ndata = @transform(sdata, {"z"} = {"x"} - 2 * {"y"})
    @test ndata.z == sdata.x .- 2 .* sdata.y

    xnm, ynm, znm = :x, :y, :z
    ndata = @transform(sdata, {znm} = {xnm} - 2 * {ynm})
    @test ndata.z == sdata.x .- 2 .* sdata.y

    # variable interpolation
    z = rand(10)
    ndata = @transform(sdata, :z = z, :w = :x - z)
    @test ndata.z == z
    @test ndata.w == sdata.x .- z

    # column replacement
    table = (x=rand(10), y=rand(10), z=rand(10))
    sdata = georef(table, rand(2, 10))

    ndata = @transform(sdata, :z = :x + :y, :w = :x - :y)
    @test ndata.z == sdata.x .+ sdata.y
    @test ndata.w == sdata.x .- sdata.y
    @test Tables.schema(values(ndata)).names == (:x, :y, :z, :w)

    ndata = @transform(sdata, :x = :y, :y = :z, :z = :x)
    @test ndata.x == sdata.y
    @test ndata.y == sdata.z
    @test ndata.z == sdata.x
    @test Tables.schema(values(ndata)).names == (:x, :y, :z)

    # missing values
    x = [1, 1, missing, missing, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, missing, missing]
    table = (; x, y)
    sdata = georef(table, rand(8, 2))

    ndata = @transform(sdata, :z = :x * :y, :w = :x / :y)
    @test isequal(ndata.z, sdata.x .* sdata.y)
    @test isequal(ndata.w, sdata.x ./ sdata.y)

    # Partition
    x = [1, 1, 1, 1, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, 4, 4]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    p = @groupby(sdata, :x, :y)
    np = @transform(p, :z = 2 * :x + :y)
    @test np.object.z == 2 .* sdata.x .+ sdata.y
    @test indices(np) == indices(p)
    @test metadata(np) == metadata(p)

    @test_throws ArgumentError @transform(p, :x = 3 * :x)
    @test_throws ArgumentError @transform(p, :y = 3 * :y)
  end

  @testset "@combine" begin
    x = [1, 1, 1, 1, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, 4, 4]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    grid = CartesianGrid(2, 4)
    sdata = georef(table, grid)

    c = @combine(sdata, :x_sum = sum(:x))
    @test c.x_sum == [sum(sdata.x)]
    @test domain(c) == GeometrySet([Multi(domain(sdata))])
    @test Tables.schema(values(c)).names == (:x_sum,)

    c = @combine(sdata, :y_mean = mean(:y), :z_median = median(:z))
    @test c.y_mean == [mean(sdata.y)]
    @test c.z_median == [median(sdata.z)]
    @test domain(c) == GeometrySet([Multi(domain(sdata))])
    @test Tables.schema(values(c)).names == (:y_mean, :z_median)

    # column name interpolation
    c = @combine(sdata, {"z"} = sum({"x"}) + prod({"y"}))
    @test c.z == [sum(sdata.x) + prod(sdata.y)]

    xnm, ynm, znm = :x, :y, :z
    c = @combine(sdata, {znm} = sum({xnm}) + prod({ynm}))
    @test c.z == [sum(sdata.x) + prod(sdata.y)]

    # Partition
    p = @groupby(sdata, :x)
    c = @combine(p, :y_sum = sum(:y), :z_prod = prod(:z))
    @test c.x == [first(data.x) for data in p]
    @test c.y_sum == [sum(data.y) for data in p]
    @test c.z_prod == [prod(data.z) for data in p]
    @test domain(c) == GeometrySet([Multi(domain(data)) for data in p])
    @test Tables.schema(values(c)).names == (:x, :y_sum, :z_prod)

    p = @groupby(sdata, :x, :y)
    c = @combine(p, :z_mean = mean(:z))
    @test c.x == [first(data.x) for data in p]
    @test c.y == [first(data.y) for data in p]
    @test c.z_mean == [mean(data.z) for data in p]
    @test domain(c) == GeometrySet([Multi(domain(data)) for data in p])
    @test Tables.schema(values(c)).names == (:x, :y, :z_mean)
  end
end

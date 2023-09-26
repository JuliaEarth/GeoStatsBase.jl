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
    @test dtable.nmissing == count.(ismissing, columns)

    dtable = describe(sdata, funs=[mean, median, std])
    @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == mean.(columns)
    @test dtable.median == median.(columns)
    @test dtable.std == std.(columns)

    dtable = describe(sdata, funs=[:mean => x -> sum(x) / length(x), :min => minimum])
    @test Tables.schema(dtable).names == (:variable, :mean, :min)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == sum.(columns) ./ length.(columns)
    @test dtable.min == minimum.(columns)

    dtable = describe(sdata, funs=Dict(:mean => x -> sum(x) / length(x), :max => maximum))
    @test Set(Tables.schema(dtable).names) == Set([:variable, :mean, :max])
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == sum.(columns) ./ length.(columns)
    @test dtable.max == maximum.(columns)

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
      @test dtable.nmissing == count.(ismissing, columns)
    end

    for colspec in colspecs
      dtable = describe(sdata, colspec; funs)
      @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
      @test dtable.variable == [:y, :z]
      @test dtable.mean == mean.(columns)
      @test dtable.median == median.(columns)
      @test dtable.std == std.(columns)
    end

    # missing values
    a = shuffle([rand(10); fill(missing, 5)])
    b = shuffle([rand(10); fill(missing, 5)])
    table = (; a, b)
    sdata = georef(table, rand(2, 10))
    columns = [a, b]

    dtable = describe(sdata)
    @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
    @test dtable.variable == [:a, :b]
    @test dtable.mean == GeoStatsBase._skipmissing(mean).(columns)
    @test dtable.minimum == GeoStatsBase._skipmissing(minimum).(columns)
    @test dtable.median == GeoStatsBase._skipmissing(median).(columns)
    @test dtable.maximum == GeoStatsBase._skipmissing(maximum).(columns)
    @test dtable.nmissing == count.(ismissing, columns)    
  end

  @testset "integrate" begin
    grid = CartesianGrid(2, 2)
    mesh = simplexify(grid)
    table = (z=[1, 2, 3, 4, 5, 6, 7, 8, 9], w=[1, 1, 1, 2, 2, 2, 3, 3, 3])
    gdata = GeoTable(grid, vtable=table)
    mdata = GeoTable(mesh, vtable=table)
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
    @test all(nrow.(g) .== 1)
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

    # replace :geometry column
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

  @testset "geosplit" begin
    d = CartesianGrid(10, 10)
    l, r = geosplit(d, 0.5)
    @test nelements(l) == 50
    @test nelements(r) == 50
    l, r = geosplit(d, 0.5, (1.0, 0.0))
    @test nelements(l) == 50
    @test nelements(r) == 50
    lpts = [centroid(l, i) for i in 1:nelements(l)]
    rpts = [centroid(r, i) for i in 1:nelements(r)]
    cl = mean(coordinates.(lpts))
    cr = mean(coordinates.(rpts))
    @test cl[1] < cr[1]
    @test cl[2] == cr[2]
    l, r = geosplit(d, 0.5, (0.0, 1.0))
    @test nelements(l) == 50
    @test nelements(r) == 50
    lpts = [centroid(l, i) for i in 1:nelements(l)]
    rpts = [centroid(r, i) for i in 1:nelements(r)]
    cl = mean(coordinates.(lpts))
    cr = mean(coordinates.(rpts))
    @test cl[1] == cr[1]
    @test cl[2] < cr[2]
  end

  @testset "geojoin" begin
    poly1 = PolyArea((1, 1), (5, 1), (3, 3))
    poly2 = PolyArea((6, 0), (10, 0), (10, 8))
    poly3 = PolyArea((1, 4), (4, 4), (6, 6), (3, 6))
    poly4 = PolyArea((1, 8), (4, 7), (7, 8), (5, 10), (3, 10))
    pset = PointSet((3, 2), (3, 3), (9, 2), (8, 2), (6, 4), (4, 5), (3, 5), (5, 9), (3, 9))
    gset = GeometrySet([poly1, poly2, poly3, poly4])
    grid = CartesianGrid(10, 10)
    linds = LinearIndices(size(grid))
    pointquads = [
      [linds[3, 2], linds[4, 2], linds[3, 3], linds[4, 3]],
      [linds[3, 3], linds[4, 3], linds[3, 4], linds[4, 4]],
      [linds[9, 2], linds[10, 2], linds[9, 3], linds[10, 3]],
      [linds[8, 2], linds[9, 2], linds[8, 3], linds[9, 3]],
      [linds[6, 4], linds[7, 4], linds[6, 5], linds[7, 5]],
      [linds[4, 5], linds[5, 5], linds[4, 6], linds[5, 6]],
      [linds[3, 5], linds[4, 5], linds[3, 6], linds[4, 6]],
      [linds[5, 9], linds[6, 9], linds[5, 10], linds[6, 10]],
      [linds[3, 9], linds[4, 9], linds[3, 10], linds[4, 10]]
    ]
    gtb1 = georef((; a=1:4), gset)
    gtb2 = georef((; b=rand(9)), pset)
    gtb3 = georef((; c=1:100), grid)

    # left join
    jgtb = geojoin(gtb1, gtb2)
    @test propertynames(jgtb) == [:a, :b, :geometry]
    @test jgtb.geometry == gtb1.geometry
    @test jgtb.a == gtb1.a
    @test jgtb.b[1] == mean(gtb2.b[[1, 2]])
    @test jgtb.b[2] == mean(gtb2.b[[3, 4]])
    @test jgtb.b[3] == mean(gtb2.b[[6, 7]])
    @test jgtb.b[4] == mean(gtb2.b[[8, 9]])

    jgtb = geojoin(gtb1, gtb2, :b => std)
    @test propertynames(jgtb) == [:a, :b, :geometry]
    @test jgtb.geometry == gtb1.geometry
    @test jgtb.a == gtb1.a
    @test jgtb.b[1] == std(gtb2.b[[1, 2]])
    @test jgtb.b[2] == std(gtb2.b[[3, 4]])
    @test jgtb.b[3] == std(gtb2.b[[6, 7]])
    @test jgtb.b[4] == std(gtb2.b[[8, 9]])

    jgtb = geojoin(gtb2, gtb1)
    @test propertynames(jgtb) == [:b, :a, :geometry]
    @test jgtb.geometry == gtb2.geometry
    @test jgtb.b == gtb2.b
    @test isequal(jgtb.a, [1, 1, 2, 2, missing, 3, 3, 4, 4])

    jgtb = geojoin(gtb3, gtb1, pred=issubset)
    @test propertynames(jgtb) == [:c, :a, :geometry]
    @test jgtb.geometry == gtb3.geometry
    @test jgtb.c == gtb3.c
    @test jgtb.a[linds[9, 2]] == 2
    @test jgtb.a[linds[9, 3]] == 2
    @test jgtb.a[linds[5, 9]] == 4
    @test jgtb.a[linds[4, 9]] == 4

    jgtb = geojoin(gtb2, gtb3, :c => last, pred=issubset)
    @test propertynames(jgtb) == [:b, :c, :geometry]
    @test jgtb.geometry == gtb2.geometry
    @test jgtb.b == gtb2.b
    @test jgtb.c[1] == last(gtb3.c[pointquads[1]])
    @test jgtb.c[2] == last(gtb3.c[pointquads[2]])
    @test jgtb.c[3] == last(gtb3.c[pointquads[3]])
    @test jgtb.c[4] == last(gtb3.c[pointquads[4]])
    @test jgtb.c[5] == last(gtb3.c[pointquads[5]])
    @test jgtb.c[6] == last(gtb3.c[pointquads[6]])
    @test jgtb.c[7] == last(gtb3.c[pointquads[7]])
    @test jgtb.c[8] == last(gtb3.c[pointquads[8]])
    @test jgtb.c[9] == last(gtb3.c[pointquads[9]])

    # inner join
    jgtb = geojoin(gtb1, gtb2, :b => std, kind=:inner)
    @test propertynames(jgtb) == [:a, :b, :geometry]
    @test jgtb.geometry == gtb1.geometry
    @test jgtb.a == gtb1.a
    @test jgtb.b[1] == std(gtb2.b[[1, 2]])
    @test jgtb.b[2] == std(gtb2.b[[3, 4]])
    @test jgtb.b[3] == std(gtb2.b[[6, 7]])
    @test jgtb.b[4] == std(gtb2.b[[8, 9]])

    jgtb = geojoin(gtb2, gtb1, kind=:inner)
    inds = [1, 2, 3, 4, 6, 7, 8, 9]
    @test propertynames(jgtb) == [:b, :a, :geometry]
    @test jgtb.geometry == view(gtb2.geometry, inds)
    @test jgtb.b == gtb2.b[inds]
    @test jgtb.a == [1, 1, 2, 2, 3, 3, 4, 4]

    jgtb = geojoin(gtb3, gtb2, :b => last, kind=:inner)
    inds = sort(unique(reduce(vcat, pointquads)))
    @test propertynames(jgtb) == [:c, :b, :geometry]
    @test jgtb.geometry == view(gtb3.geometry, inds)
    @test jgtb.c == gtb3.c[inds]
    @test jgtb.b[findfirst(==(pointquads[1][2]), inds)] == gtb2.b[1]
    @test jgtb.b[findfirst(==(pointquads[2][2]), inds)] == gtb2.b[2]
    @test jgtb.b[findfirst(==(pointquads[3][2]), inds)] == gtb2.b[3]
    @test jgtb.b[findfirst(==(pointquads[4][2]), inds)] == gtb2.b[4]
    @test jgtb.b[findfirst(==(pointquads[5][2]), inds)] == gtb2.b[5]
    @test jgtb.b[findfirst(==(pointquads[6][2]), inds)] == gtb2.b[6]
    @test jgtb.b[findfirst(==(pointquads[7][2]), inds)] == gtb2.b[7]
    @test jgtb.b[findfirst(==(pointquads[8][2]), inds)] == gtb2.b[8]
    @test jgtb.b[findfirst(==(pointquads[9][2]), inds)] == gtb2.b[9]

    # units
    gtb4 = georef((; d=rand(9) * u"K"), pset)
    jgtb = geojoin(gtb1, gtb4)
    @test propertynames(jgtb) == [:a, :d, :geometry]
    @test jgtb.geometry == gtb1.geometry
    @test jgtb.a == gtb1.a
    @test GeoStatsBase.elunit(jgtb.d) == u"K"
    @test jgtb.d[1] == mean(gtb4.d[[1, 2]])
    @test jgtb.d[2] == mean(gtb4.d[[3, 4]])
    @test jgtb.d[3] == mean(gtb4.d[[6, 7]])
    @test jgtb.d[4] == mean(gtb4.d[[8, 9]])

    # affine units
    gtb5 = georef((; e=rand(9) * u"°C"), pset)
    jgtb = geojoin(gtb1, gtb5)
    ngtb = GeoStatsBase.uadjust(gtb5)
    @test propertynames(jgtb) == [:a, :e, :geometry]
    @test jgtb.geometry == gtb1.geometry
    @test jgtb.a == gtb1.a
    @test GeoStatsBase.elunit(jgtb.e) == u"K"
    @test jgtb.e[1] == mean(ngtb.e[[1, 2]])
    @test jgtb.e[2] == mean(ngtb.e[[3, 4]])
    @test jgtb.e[3] == mean(ngtb.e[[6, 7]])
    @test jgtb.e[4] == mean(ngtb.e[[8, 9]])

    # units and missings
    gtb6 = georef((; f=[rand(4); missing; rand(4)] * u"°C"), pset)
    jgtb = geojoin(gtb1, gtb6)
    ngtb = GeoStatsBase.uadjust(gtb6)
    @test propertynames(jgtb) == [:a, :f, :geometry]
    @test jgtb.geometry == gtb1.geometry
    @test jgtb.a == gtb1.a
    @test GeoStatsBase.elunit(jgtb.f) == u"K"
    @test jgtb.f[1] == mean(ngtb.f[[1, 2]])
    @test jgtb.f[2] == mean(ngtb.f[[3, 4]])
    @test jgtb.f[3] == mean(ngtb.f[[6, 7]])
    @test jgtb.f[4] == mean(ngtb.f[[8, 9]])
  end
end

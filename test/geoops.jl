@testset "Geometric operations" begin
  @testset "unique" begin
    X = [i*j for i in 1:2, j in 1:1_000_000]
    z = rand(1_000_000)
    d = georef((z=[z;z],), [X X])
    u = uniquecoords(d)
    p = [centroid(u, i) for i in 1:nelements(u)]
    U = reduce(hcat, coordinates.(p))
    @test nelements(u) == 1_000_000
    @test Set(eachcol(U)) == Set(eachcol(X))

    X = rand(3,100)
    z = rand(100)
    n = [string(i) for i in 1:100]
    Xd = hcat(X, X[:,1:10])
    zd = vcat(z, z[1:10])
    nd = vcat(n, n[1:10])
    sdata = georef((z=zd, n=nd), PointSet(Xd))
    ndata = uniquecoords(sdata)
    @test nelements(ndata) == 100
  end

  @testset "groupby" begin
    d = georef((z=[1,2,3],x=[4,5,6]), rand(2,3))
    g = @groupby(d, :z)
    @test all(nelements.(g) .== 1)
    rows = [[1 4], [2 5], [3 6]]
    for i in 1:3
      @test Tables.matrix(values(g[i])) ∈ rows
    end

    z = vec([1 1 1; 2 2 2; 3 3 3])
    sdata = georef((z=z,), CartesianGrid(3,3))
    p = @groupby(sdata, :z)
    @test indices(p) == [[1,4,7],[2,5,8],[3,6,9]]

    # groupby with missing values
    z = vec([missing 1 1; 2 missing 2; 3 3 missing])
    sdata = georef((z=z,), CartesianGrid(3,3))
    p = @groupby(sdata, :z)
    @test indices(p) == [[1,5,9],[2,8],[3,6],[4,7]]

    # macro
    x = [1, 1, 1, 1, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, 4, 4]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    # args...
    # integers
    p = @groupby(sdata, 1)
    @test indices(p) == [[1,2,3,4],[5,6,7,8]]
    # symbols
    p = @groupby(sdata, :y)
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]
    # strings
    p = @groupby(sdata, "x", "y")
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    # vector...
    # integers
    p = @groupby(sdata, [1])
    @test indices(p) == [[1,2,3,4],[5,6,7,8]]
    # symbols
    p = @groupby(sdata, [:y])
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]
    # strings
    p = @groupby(sdata, ["x", "y"])
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    # tuple...
    # integers
    p = @groupby(sdata, (1,))
    @test indices(p) == [[1,2,3,4],[5,6,7,8]]
    # symbols
    p = @groupby(sdata, (:y,))
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]
    # strings
    p = @groupby(sdata, ("x", "y"))
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    # regex
    p = @groupby(sdata, r"[xy]")
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    # variable interpolation
    cols = (:x, :y)
    p = @groupby(sdata, cols)
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]
    p = @groupby(sdata, cols...)
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    c1, c2 = :x, :y
    p = @groupby(sdata, c1, c2)
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]
    p = @groupby(sdata, [c1, c2])
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]
    p = @groupby(sdata, (c1, c2))
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    # missing values
    x = [1, 1, missing, missing, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, missing, missing]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    p = @groupby(sdata, :x)
    @test indices(p) == [[1,2],[3,4],[5,6,7,8]]
    p = @groupby(sdata, :x, :y)
    @test indices(p) == [[1,2],[3,4],[5,6],[7,8]]

    # isequal
    x = [0.0, 0, 0, -0.0, 2, 2, 2, 2]
    y = [1, 1, 2, 2, 3, 3, 4, 4]
    z = [1, 2, 3, 4, 5, 6, 7, 8]
    table = (; x, y, z)
    sdata = georef(table, rand(2, 8))

    p = @groupby(sdata, :x)
    @test indices(p) == [[1,2,3],[4],[5,6,7,8]]
    p = @groupby(sdata, :x, :y)
    @test indices(p) == [[1,2],[3],[4],[5,6],[7,8]]
  end

  @testset "filter" begin
    𝒟 = georef((a=[1,2,3], b=[1,1,missing]))
    𝒫 = filter(s -> !ismissing(s.b), 𝒟)
    @test 𝒫[:a] == [1,2]
    @test 𝒫[:b] == [1,1]

    𝒟 = georef((a=[1,2,3],b=[3,2,1]))
    𝒫ₐ = filter(s -> s.a > 1, 𝒟)
    𝒫ᵦ = filter(s -> s.b > 1, 𝒟)
    𝒫ₐᵦ = filter(s -> s.a > 1 && s.b > 1, 𝒟)
    @test nelements(𝒫ₐ) == 2
    @test nelements(𝒫ᵦ) == 2
    @test nelements(𝒫ₐᵦ) == 1
    @test 𝒫ₐ[:a] == [2,3]
    @test 𝒫ₐ[:b] == [2,1]
    @test 𝒫ᵦ[:a] == [1,2]
    @test 𝒫ᵦ[:b] == [3,2]
    @test 𝒫ₐᵦ[:a] == [2]
    @test 𝒫ₐᵦ[:b] == [2]
  end

  @testset "integrate" begin
    grid  = CartesianGrid(2,2)
    mesh  = simplexify(grid)
    table = (z=[1,2,3,4,5,6,7,8,9], w=[1,1,1,2,2,2,3,3,3])
    gdata = meshdata(grid, vtable=table)
    mdata = meshdata(mesh, vtable=table)
    ginte = integrate(gdata, :z, :w)
    minte = integrate(mdata, :z, :w)
    @test ginte.z == [3.,4.,6.,7.]
    @test ginte.w == [1.5,1.5,2.5,2.5]
    @test sum.(Iterators.partition(minte.z, 2)) == ginte.z
    @test sum.(Iterators.partition(minte.w, 2)) == ginte.w
  end
end

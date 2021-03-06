# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@userplot HScatter

@recipe function f(hs::HScatter; lag=0, tol=1e-1, distance=Euclidean())
  # get inputs
  sdata = hs.args[1]
  var₁ = hs.args[2]
  var₂ = length(hs.args) == 3 ? hs.args[3] : var₁

  # lookup valid data
  locs₁ = findall(!ismissing, sdata[var₁])
  locs₂ = findall(!ismissing, sdata[var₂])
  𝒟₁ = view(sdata, locs₁)
  𝒟₂ = view(sdata, locs₂)
  X₁ = [coordinates(centroid(𝒟₁, i)) for i in 1:nelements(𝒟₁)]
  X₂ = [coordinates(centroid(𝒟₂, i)) for i in 1:nelements(𝒟₂)]
  z₁ = 𝒟₁[var₁]
  z₂ = 𝒟₂[var₂]

  # compute pairwise distance
  m, n = length(z₁), length(z₂)
  pairs = [(i,j) for j in 1:n for i in j:m]
  ds = [evaluate(distance, X₁[i], X₂[j]) for (i,j) in pairs]

  # find indices with given lag
  match = findall(abs.(ds .- lag) .< tol)

  if isempty(match)
    @warn "no points were found with lag = $lag, skipping..."
    return nothing
  end

  # scatter plot coordinates
  mpairs = view(pairs, match)
  x = z₁[first.(mpairs)]
  y = z₂[last.(mpairs)]

  x̄ = mean(x)
  ȳ = mean(y)

  xguide --> var₁
  yguide --> var₂

  # plot h-scatter
  @series begin
    seriestype --> :scatter
    seriescolor --> :black
    label --> "samples"

    x, y
  end

  # plot regression line
  @series begin
    seriestype --> :path
    seriescolor --> :red
    label --> "regression"

    X = [x ones(length(x))]
    ŷ = X * (X \ y)

    x, ŷ
  end

  # plot identity line
  @series begin
    seriestype --> :path
    seriescolor --> :black
    linestyle --> :dash
    label --> "identity"

    xmin, xmax = extrema(x)
    ymin, ymax = extrema(y)
    vmin = min(xmin, ymin)
    vmax = max(xmax, ymax)

    [vmin, vmax], [vmin, vmax]
  end

  # plot mean lines
  @series begin
    primary --> false
    seriestype --> :vline
    seriescolor --> :green
    [x̄]
  end
  @series begin
    primary --> false
    seriestype --> :hline
    seriescolor --> :green
    [ȳ]
  end
  @series begin
    primary --> false
    seriestype --> :scatter
    seriescolor --> :green
    marker --> :square
    markersize --> 4
    [(x̄, ȳ)]
  end
end

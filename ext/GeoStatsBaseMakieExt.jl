# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBaseMakieExt

using GeoStatsBase

using Meshes
using Unitful
using GeoTables
using Distances

import Makie
import GeoStatsBase: hscatter, hscatter!

# --------------------
# EMPIRICAL HISTOGRAM
# --------------------

Makie.plottype(::EmpiricalHistogram) = Makie.Hist
Makie.convert_arguments(P::Type{<:Makie.Hist}, h::EmpiricalHistogram) = Makie.convert_arguments(P, h.hist)

# ---------
# HSCATTER
# ---------

Makie.@recipe HScatter (gtb, var₁, var₂) begin
  lag = 0.0u"m"
  tol = 0.1u"m"
  distance = Euclidean()
  size = 2
  color = :black
  alpha = 1.0
  rcolor = :salmon
  icolor = :black
  ccolor = :teal
end

Makie.preferred_axis_attributes(_, plot::HScatter) =
  (aspect=Makie.DataAspect(), xlabel=string(plot.var₁[]), ylabel=string(plot.var₂[]))

function Makie.plot!(plot::HScatter)
  # visualize h-scatter
  Makie.map!(plot, [:gtb, :var₁, :var₂, :lag, :tol, :distance], [:x, :y]) do gtb, var₁, var₂, lag, tol, distance
    _hscatter(gtb, var₁, var₂, aslen(lag), aslen(tol), distance)
  end

  # compute regression line and identity line limits
  Makie.map!(plot, [:x, :y], [:x̄, :ȳ, :ŷ, :minmax]) do x, y
    x̄, ȳ = mean(x), mean(y)
    X = [x ones(length(x))]
    ŷ = X * (X \ y)
    a, b = extrema([extrema(x)..., extrema(y)...])
    x̄, ȳ, ŷ, [(a, a), (b, b)]
  end

  # visualize h-scatter points
  Makie.scatter!(plot, plot.x, plot.y, color=plot.color, alpha=plot.alpha, markersize=plot.size)

  # visualize regression line
  Makie.lines!(plot, plot.x, plot.ŷ, color=plot.rcolor)

  # visualize identity line
  Makie.lines!(plot, plot.minmax, color=plot.icolor)

  # visualize center lines
  Makie.vlines!(plot, plot.x̄, color=plot.ccolor)
  Makie.hlines!(plot, plot.ȳ, color=plot.ccolor)

  # visualize center point
  Makie.scatter!(plot, plot.x̄, plot.ȳ, color=plot.ccolor, marker=:rect, markersize=16)
end

function _hscatter(gtb, var₁, var₂, lag, tol, distance)
  # lookup valid data
  𝒮₁ = view(gtb, findall(!ismissing, gtb[:, var₁]))
  𝒮₂ = view(gtb, findall(!ismissing, gtb[:, var₂]))
  𝒟₁ = domain(𝒮₁)
  𝒟₂ = domain(𝒮₂)
  x₁ = [to(centroid(𝒟₁, i)) for i in 1:nelements(𝒟₁)]
  x₂ = [to(centroid(𝒟₂, i)) for i in 1:nelements(𝒟₂)]
  z₁ = getproperty(𝒮₁, var₁)
  z₂ = getproperty(𝒮₂, var₂)

  # compute pairwise distance
  m, n = length(z₁), length(z₂)
  pairs = [(i, j) for j in 1:n for i in j:m]
  ds = [distance(x₁[i], x₂[j]) for (i, j) in pairs]

  # find indices with given lag
  match = findall(abs.(ds .- lag) .< tol)

  if isempty(match)
    throw(ErrorException("No points were found with lag = $lag, aborting..."))
  end

  # h-scatter coordinates
  mpairs = view(pairs, match)
  x = z₁[first.(mpairs)]
  y = z₂[last.(mpairs)]

  x, y
end

const Len{T} = Quantity{T,u"𝐋"}

aslen(x::Len) = x
aslen(x::Number) = x * u"m"
aslen(::Quantity) = throw(ArgumentError("invalid length unit"))

end

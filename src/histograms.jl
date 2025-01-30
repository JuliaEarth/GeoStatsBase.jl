# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EmpiricalHistogram(geotable, column, [side]; kwargs...)

Declustered histogram of given `column` in `geotable`.
Optionally, specify the declustering block `side`, and
the keyword arguments `kwargs` for the underlying
`fit(Histogram, ...)` call.
"""
struct EmpiricalHistogram{H}
  hist::H
end

EmpiricalHistogram(d::AbstractGeoTable, v, w::WeightingMethod; kwargs...) =
  EmpiricalHistogram(fit(Histogram, getproperty(d, v), weight(d, w); kwargs...))

EmpiricalHistogram(d::AbstractGeoTable, v, s::Number; kwargs...) =
  EmpiricalHistogram(d, v, BlockWeighting(s); kwargs...)

EmpiricalHistogram(d::AbstractGeoTable, v; kwargs...) = EmpiricalHistogram(d, v, median_heuristic(d); kwargs...)

"""
    values(histogram)
    
Return the abscissa and ordinates of empirical `histogram`.
"""
Base.values(h::EmpiricalHistogram) = midpoints(first(h.hist.edges)), h.hist.weights

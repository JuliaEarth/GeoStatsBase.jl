# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
EmpiricalHistogram(sdata)
EmpiricalHistogram(sdata, v; kwargs...)
EmpiricalHistogram(sdata, v, s; kwargs...)

Spatial histogram of spatial data `sdata`. Optionally,
specify the variable `v`, the block side `s`, and the
keyword arguments `kwargs` for `fit(Histotogram, ...)`.
"""
struct EmpiricalHistogram{H}
  hist::H
end

EmpiricalHistogram(d, v::Symbol, w::WeightingMethod; kwargs...) = fit(Histogram, d[v], weight(d, w); kwargs...)
EmpiricalHistogram(d, v::Symbol, s::Number; kwargs...) = EmpiricalHistogram(d, v, BlockWeighting(ntuple(i->s,ncoords(d))); kwargs...)
EmpiricalHistogram(d, v::Symbol; kwargs...) = EmpiricalHistogram(d, v, median_heuristic(d); kwargs...)
EmpiricalHistogram(d, w::WeightingMethod; kwargs...) = Dict(v => EmpiricalHistogram(d, v, w; kwargs...) for v in name.(variables(d)))
EmpiricalHistogram(d, s::Number; kwargs...) = EmpiricalHistogram(d, BlockWeighting(ntuple(i->s,ncoords(d))); kwargs...)
EmpiricalHistogram(d; kwargs...) = EmpiricalHistogram(d, median_heuristic(d); kwargs...)
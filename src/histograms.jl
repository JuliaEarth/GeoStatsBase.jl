# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EmpiricalHistogram(sdata, var, [s]; kwargs...)

Spatial histogram of variable `var` in spatial data `sdata`.
Optionally, specify the block side `s` and the keyword
arguments `kwargs` for the `fit(Histogram, ...)` call.
"""
struct EmpiricalHistogram{H}
  hist::H
end

EmpiricalHistogram(d, v::Symbol, w::WeightingMethod; kwargs...) = EmpiricalHistogram(fit(Histogram, d[v], weight(d, w); kwargs...))
EmpiricalHistogram(d, v::Symbol, s::Number; kwargs...) = EmpiricalHistogram(d, v, BlockWeighting(ntuple(i->s,ncoords(d))); kwargs...)
EmpiricalHistogram(d, v::Symbol; kwargs...) = EmpiricalHistogram(d, v, median_heuristic(d); kwargs...)
EmpiricalHistogram(d, w::WeightingMethod; kwargs...) = Dict(v => EmpiricalHistogram(d, v, w; kwargs...) for v in name.(variables(d)))
EmpiricalHistogram(d, s::Number; kwargs...) = EmpiricalHistogram(d, BlockWeighting(ntuple(i->s,ncoords(d))); kwargs...)

Base.values(h::EmpiricalHistogram) = midpoints(first(h.hist.edges)), h.hist.weights

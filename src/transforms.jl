# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

divide(data::Data) = values(data), domain(data)
attach(table, dom::Domain) = georef(table, dom)

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/basic.jl")
include("transforms/geometric.jl")
include("transforms/detrend.jl")
include("transforms/potrace.jl")
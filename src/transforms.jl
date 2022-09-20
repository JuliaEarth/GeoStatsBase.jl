# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

TT.divide(data::Data) = values(data), domain(data)
TT.attach(table, dom::Domain) = georef(table, dom)

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/basic.jl")
include("transforms/detrend.jl")
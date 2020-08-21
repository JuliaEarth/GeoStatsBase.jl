# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RegularGridDiscretizer(dims)

Discretize spatial region into regular grid of given
dimensions `dims`.
"""
struct RegularGridDiscretizer{N} <: AbstractDiscretizer
  dims::Dims{N}
end

discretize(r::Rectangle, d::RegularGridDiscretizer) =
  RegularGrid(extrema(r)..., dims=d.dims)

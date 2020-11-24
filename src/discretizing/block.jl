# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockDiscretization(dims)

Discretize spatial region into `dims` blocks.
"""
struct BlockDiscretization{N} <: DiscretizationMethod
  dims::Dims{N}
end

discretize(r::Rectangle, method::BlockDiscretization) =
  RegularGrid(extrema(r)..., dims=method.dims)

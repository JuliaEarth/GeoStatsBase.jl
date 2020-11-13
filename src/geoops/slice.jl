# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    slice(object, xmin:xmax, ymin:ymax, ...)

Slice spatial `object` using real coordinate ranges
`xmin:xmax`, `ymin:ymax`, ...
"""
slice(object, ranges::Vararg) =
  inside(object, Rectangle(first.(ranges), last.(ranges)))
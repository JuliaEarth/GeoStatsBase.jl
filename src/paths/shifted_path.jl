# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    ShiftedPath(path, offset)

Produces the same results of `path` but shifted by an `offset`
that can be positive or negative.
"""
struct ShiftedPath{D<:AbstractDomain,P<:AbstractPath{D}} <: AbstractPath{D}
  path::P
  offset::Int
  start::Int
  length::Int
end

function ShiftedPath(path::AbstractPath{D}, offset::Int) where {D<:AbstractDomain}
  _, s = iterate(path)
  start = s - 1
  len = length(path)
  off = offset ≥ 0 ? offset : len + offset

  ShiftedPath{D,typeof(path)}(path, off, start, len)
end

function Base.iterate(path::ShiftedPath, state=1)
  if state > path.length
    nothing
  else
    s = ((state + path.offset - 1) % path.length) + path.start
    loc, _ = iterate(path.path, s)
    loc, state + 1
  end
end

Base.length(path::ShiftedPath) = path.length

# ------------
# IO methods
# ------------
function Base.show(io::IO, path::ShiftedPath)
  print(io, "ShiftedPath")
end

function Base.show(io::IO, ::MIME"text/plain", path::ShiftedPath)
  println(io, path)
end

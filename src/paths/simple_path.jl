# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SimplePath(domain)

A simple (or default) path on a spatial `domain`.
"""
struct SimplePath{D<:AbstractDomain} <: AbstractPath{D}
  domain::D
end

Base.iterate(p::SimplePath, state=1) = state > npoints(p.domain) ? nothing : (state, state + 1)

# ------------
# IO methods
# ------------
function Base.show(io::IO, path::SimplePath)
  print(io, "SimplePath")
end

function Base.show(io::IO, ::MIME"text/plain", path::SimplePath)
  println(io, path)
end

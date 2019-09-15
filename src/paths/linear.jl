# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    LinearPath(domain)

A linear path on spatial `domain`.
"""
struct LinearPath{D<:AbstractDomain} <: AbstractPath{D}
  domain::D
end

Base.iterate(p::LinearPath, state=1) = state > npoints(p.domain) ? nothing : (state, state + 1)

# ------------
# IO methods
# ------------
function Base.show(io::IO, path::LinearPath)
  print(io, "LinearPath")
end

function Base.show(io::IO, ::MIME"text/plain", path::LinearPath)
  println(io, path)
end

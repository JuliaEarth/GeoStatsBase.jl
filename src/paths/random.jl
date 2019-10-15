# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RandomPath(domain)

A random path on a spatial `domain`.
"""
struct RandomPath{D<:AbstractDomain} <: AbstractPath{D}
  domain::D
  permut::Vector{Int}

  function RandomPath{D}(domain, permut) where {D<:AbstractDomain}
    @assert length(permut) == npoints(domain) "incorrect dimension"
    new(domain, permut)
  end
end

RandomPath(domain) = RandomPath{typeof(domain)}(domain, randperm(npoints(domain)))

Base.iterate(p::RandomPath, state=1) = state > npoints(p.domain) ? nothing : (p.permut[state], state + 1)

# ------------
# IO methods
# ------------
function Base.show(io::IO, path::RandomPath)
  print(io, "RandomPath")
end

function Base.show(io::IO, ::MIME"text/plain", path::RandomPath)
  println(io, path)
end

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ProductPartitioner(p₁, p₂)

A method for partitioning spatial objects using the product of two
partitioners `p₁` and `p₂`.
"""
struct ProductPartitioner{P1<:AbstractPartitioner,
                          P2<:AbstractPartitioner} <: AbstractPartitioner
  p₁::P1
  p₂::P2
end

# general case
function partition(object::AbstractSpatialObject{T,N},
                   partitioner::ProductPartitioner) where {N,T}
  # individual partition results
  s₁ = subsets(partition(object, partitioner.p₁))
  s₂ = subsets(partition(object, partitioner.p₂))

  # label-based representation
  l₁ = Vector{Int}(undef, npoints(object))
  l₂ = Vector{Int}(undef, npoints(object))
  for (i, inds) in enumerate(s₁)
    l₁[inds] .= i
  end
  for (i, inds) in enumerate(s₂)
    l₂[inds] .= i
  end

  # product of labels
  counter = 0
  d = Dict{Tuple{Int,Int},Int}()
  l = Vector{Int}(undef, npoints(object))
  for i in 1:npoints(object)
    t = (l₁[i], l₂[i])
    if t ∉ keys(d)
      counter += 1
      d[t] = counter
    end
    l[i] = d[t]
  end

  # subset-based representation
  ss = Vector{Vector{Int}}()
  for i in 1:npoints(object)
    inserted = false
    for s in ss
      j = s[1]
      if l[i] == l[j]
        push!(s, i)
        inserted = true
        break
      end
    end

    if !inserted
      push!(ss, [i])
    end
  end

  SpatialPartition(object, ss)
end

Base.:*(p₁::AbstractPartitioner, p₂::AbstractPartitioner) =
  ProductPartitioner(p₁, p₂)

# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LabeledPointExample(data, features, label)

Generate a learning example for a supervised learning task
where each example is a point with `features` and `label` in the `data`.
"""
struct LabeledPointExample{DΩ<:AbstractData,N} <: AbstractLabeledExample
  data::DΩ
  features::NTuple{N,Symbol}
  label::Symbol
end

function Base.iterate(e::LabeledPointExample{DΩ,N}, state=1) where {DΩ,N}
  if state > npoints(e.data)
    nothing
  else
    x = SVector{N}([e.data[state,feat] for feat in e.features])
    y = e.data[state,e.label]
    ((x, y), state + 1)
  end
end

Base.length(e::LabeledPointExample) = npoints(e.data)

"""
    UnlabeledPointExample(data, features)

Generate a learning example for an unsupervised learning task
where each example is a point with `features` in the `data`.
"""
struct UnlabeledPointExample{DΩ<:AbstractData,N} <: AbstractUnlabeledExample
  data::DΩ
  features::NTuple{N,Symbol}
end

function Base.iterate(e::UnlabeledPointExample{DΩ,N}, state=1) where {DΩ,N}
  if state > npoints(e.data)
    nothing
  else
    x = SVector{N}([e.data[state,feat] for feat in e.features])
    (x, state + 1)
  end
end

Base.length(e::UnlabeledPointExample) = npoints(e.data)

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearnedModel(m, θ)

An object that stores a learning `model`
along with its learned parameters `θ`.
"""
struct LearnedModel
  model
  θ
end

"""
    learn(task, sdata, model)

Learn the `task` with `sdata` using a learning `model`.
"""
function learn(task::AbstractLearningTask, sdata, model)
  if issupervised(task)
    v = view(sdata, collect(features(task)))
    X = values(v)
    y = sdata[label(task)]
    θ, _, __ = MI.fit(model, 0, X, y)
  else
    v = view(sdata, collect(features(task)))
    X = values(v)
    θ, _, __ = MI.fit(model, 0, X)
  end

  LearnedModel(model, θ)
end

"""
    perform(task, sdata, lmodel)

Perform the `task` with `sdata` using a *learned* `lmodel`.
"""
function perform(task::AbstractLearningTask, sdata, lmodel)
  # unpack model and learned parameters
  model, θ = lmodel.model, lmodel.θ

  # apply model to the data
  v = view(sdata, collect(features(task)))
  X = values(v)
  ŷ = MI.predict(model, θ, X)

  # post-process result
  var = outputvars(task)[1]
  val = if issupervised(task)
    isprobabilistic(model) ? mode.(ŷ) : ŷ
  else
    ŷ
  end

  ctor = constructor(typeof(sdata))
  ctor(domain(sdata), (; var=>val))
end

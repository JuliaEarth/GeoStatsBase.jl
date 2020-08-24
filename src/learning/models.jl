# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
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
    X = view(sdata, collect(features(task)))
    y = sdata[label(task)]
    θ, _, __ = MI.fit(model, 0, X, y)
  else
    X = view(sdata, collect(features(task)))
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
  X = view(sdata, collect(features(task)))
  ŷ = MI.predict(model, θ, X)

  # post-process result
  var = outputvars(task)[1]
  val = if issupervised(task)
    isprobabilistic(model) ? mode.(ŷ) : ŷ
  else
    ŷ
  end

  georef((; var=>val), domain(sdata))
end

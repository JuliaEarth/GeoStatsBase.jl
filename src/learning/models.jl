# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    LearnedModel(model, θ)

An object that stores `model` together with learned parameters `θ`.
"""
struct LearnedModel{M<:MLJBase.Model}
  model::M
  θ
end

"""
    learn(task, geodata, model)

Learn the `task` with `geodata` using a learning `model`.
"""
function learn(task::AbstractLearningTask, geodata::AbstractData, model::MLJBase.Model)
  if issupervised(task)
    X = geodata[1:npoints(geodata),collect(features(task))]
    y = geodata[1:npoints(geodata),label(task)]
    θ, _, __ = MLJBase.fit(model, 0, X, y)
  else
    X = geodata[1:npoints(geodata),collect(features(task))]
    θ, _, __ = MLJBase.fit(model, 0, X)
  end

  LearnedModel(model, θ)
end

function learn(task::CompositeTask, geodata::AbstractData, model::MLJBase.Model)
  @error "not implemented"
end

"""
    perform(task, geodata, lmodel)

Perform the `task` with `geodata` using a *learned* `lmodel`.
"""
function perform(task::AbstractLearningTask, geodata::AbstractData, lmodel::LearnedModel)
  # unpack model and learned parameters
  model, θ = lmodel.model, lmodel.θ

  # apply model to the data
  X = geodata[1:npoints(geodata),collect(features(task))]
  ŷ = MLJBase.predict(model, θ, X)

  # post-process result
  var = outputvars(task)[1]
  if issupervised(task)
    result = isprobabilistic(model) ? mode.(ŷ) : ŷ
  else
    result = ŷ
  end

  Dict(var => result)
end

function perform(task::CompositeTask, geodata::AbstractData, lmodel::LearnedModel)
  @error "not implemented"
end

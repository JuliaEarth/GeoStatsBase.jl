# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    learn(task, geodata, model)
"""
function learn(task::AbstractLearningTask, geodata::AbstractData, model::MLJBase.Model)
  npts = npoints(geodata)

  # build feature matrix (npts × nfeat)
  X = geodata[1:npts,collect(features(task))]

  if issupervised(task)
    # build label vector (npts)
    y = geodata[1:npts,label(task)]

    X, y
  else
    X
  end
end

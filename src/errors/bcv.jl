# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockCrossValidation(sides; loss=Dict())

Cross-validation with blocks of given `sides`. Optionally,
specify `loss` function from `LossFunctions.jl` for some
of the variables. If only one side is provided, then blocks
become cubes.

## References

* Roberts et al. 2017. [Cross-validation strategies for data with
  temporal, spatial, hierarchical, or phylogenetic structure]
  (https://onlinelibrary.wiley.com/doi/10.1111/ecog.02881)
* Pohjankukka et al. 2017. [Estimating the prediction performance
  of spatial models via spatial k-fold cross-validation]
  (https://www.tandfonline.com/doi/full/10.1080/13658816.2017.1346255)
"""
struct BlockCrossValidation{S} <: ErrorEstimationMethod
  sides::S
  loss::Dict{Symbol,SupervisedLoss}
end

BlockCrossValidation(sides; loss=Dict()) =
  BlockCrossValidation{typeof(sides)}(sides, loss)

function Base.error(solver, problem, method::BlockCrossValidation)
  s = method.sides
  n = embeddim(_foldable(problem))
  l = length(s) > 1 ? s : ntuple(i->s, n)

  # uniform weights
  weighting = UniformWeighting()

  # block folds
  folding = BlockFolding(l)

  wcv = WeightedCrossValidation(weighting, folding,
                                lambda=1, loss=method.loss)

  error(solver, problem, wcv)
end

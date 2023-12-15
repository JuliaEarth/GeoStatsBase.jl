# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BlockValidation(sides; loss=Dict())

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
struct BlockValidation{S} <: ErrorMethod
  sides::S
  loss::Dict{Symbol,SupervisedLoss}
end

BlockValidation(sides; loss=Dict()) = BlockValidation{typeof(sides)}(sides, loss)

function Base.error(setup, problem, method::BlockValidation)
  # uniform weights
  weighting = UniformWeighting()

  # block folds
  folding = BlockFolding(method.sides)

  wcv = WeightedValidation(weighting, folding, lambda=1, loss=method.loss)

  error(setup, problem, wcv)
end

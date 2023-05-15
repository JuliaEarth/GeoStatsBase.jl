# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    searcher_ui(domain, maxneighbors, metric, neighborhood)

Return the appropriate search method over the `domain` based on
end-user inputs such as `maxneighbors`, `metric` and `neighborhood`.
"""
function searcher_ui(domain, maxneighbors, metric, neighborhood)
  # number of domain elements
  nelem = nelements(domain)

  if isnothing(maxneighbors)
    # global search with all elements
    GlobalSearch(domain)
  else
    # upper bound in maxneighbors
    maxneighbors > nelem && (maxneighbors = nelem)
    if isnothing(neighborhood)
      # nearest neighbor search with a metric
      KNearestSearch(domain, maxneighbors, metric=metric)
    else
      # neighbor search with ball neighborhood
      KBallSearch(domain, maxneighbors, neighborhood)
    end
  end
end

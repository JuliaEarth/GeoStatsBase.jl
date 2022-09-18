# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

divide(data::Data) = values(data), domain(data)
attach(table, dom::Domain) = georef(table, dom)

function applymeta(::Filter, dom::Domain, prep)
  # preprocessed indices
  sinds, rinds = prep

  # select/reject geometries
  sdom = view(dom, sinds)
  rdom = view(dom, rinds)

  sdom, (rinds, rdom)
end

function revertmeta(::Filter, newdom::Domain, mcache)
  # collect all geometries
  geoms = collect(newdom)

  rinds, rdom = mcache
  for (i, geom) in zip(rinds, rdom)
    insert!(geoms, i, geom)
  end

  Collection(geoms)
end
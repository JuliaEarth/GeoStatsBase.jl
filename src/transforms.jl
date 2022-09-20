# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# implement TableTransforms.jl API for geospatial data

divide(data::Data) = values(data), domain(data)
attach(table, dom::Domain) = georef(table, dom)

# transforms that change the order or number of
# rows in the table need a special treatment

function applymeta(::Sort, dom::Domain, prep)
  sinds = prep

  sdom = view(dom, sinds)

  sdom, sinds
end

function revertmeta(::Sort, newdom::Domain, mcache)
  sinds = mcache
  rinds = sortperm(sinds)

  view(newdom, rinds)
end

# --------------------------------------------------

function applymeta(::Filter, dom::Domain, prep)
  sinds, rinds = prep

  sdom = view(dom, sinds)
  rdom = view(dom, rinds)

  sdom, (rinds, rdom)
end

function revertmeta(::Filter, newdom::Domain, mcache)
  geoms = collect(newdom)

  rinds, rdom = mcache
  for (i, geom) in zip(rinds, rdom)
    insert!(geoms, i, geom)
  end

  Collection(geoms)
end

# --------------------------------------------------

function applymeta(::DropMissing, dom::Domain, prep)
  ftrans, fprep, _ = prep
  newmeta, fmcache = applymeta(ftrans, dom, fprep)
  newmeta, (ftrans, fmcache)
end

function revertmeta(::DropMissing, newdom::Domain, mcache)
  ftrans, fmcache = mcache
  revertmeta(ftrans, newdom, fmcache)
end

# --------------------------------------------------

function applymeta(::Sample, dom::Domain, prep)
  sinds, rinds = prep

  sdom = view(dom, sinds)
  rdom = view(dom, rinds)

  sdom, (sinds, rinds, rdom)
end

function revertmeta(::Sample, newdom::Domain, mcache)
  geoms = collect(newdom)

  sinds, rinds, rdom = mcache

  uinds  = sort(unique(sinds))
  ugeoms = map(uinds) do i
    j = findfirst(==(i), sinds)
    geoms[j]
  end

  for (i, geom) in zip(rinds, rdom)
    insert!(ugeoms, i, geom)
  end

  Collection(ugeoms)
end
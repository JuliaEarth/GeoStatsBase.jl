# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# transforms that change the order or number of
# rows in the table need a special treatment

function TT.applymeta(::Sort, dom::Domain, prep)
  sinds = prep

  sdom = view(dom, sinds)

  sdom, sinds
end

function TT.revertmeta(::Sort, newdom::Domain, mcache)
  sinds = mcache
  rinds = sortperm(sinds)

  view(newdom, rinds)
end

# --------------------------------------------------

function TT.applymeta(::Filter, dom::Domain, prep)
  sinds, rinds = prep

  sdom = view(dom, sinds)
  rdom = view(dom, rinds)

  sdom, (rinds, rdom)
end

function TT.revertmeta(::Filter, newdom::Domain, mcache)
  geoms = collect(newdom)

  rinds, rdom = mcache
  for (i, geom) in zip(rinds, rdom)
    insert!(geoms, i, geom)
  end

  Collection(geoms)
end

# --------------------------------------------------

function TT.applymeta(::DropMissing, dom::Domain, prep)
  ftrans, fprep, _ = prep
  newmeta, fmcache = TT.applymeta(ftrans, dom, fprep)
  newmeta, (ftrans, fmcache)
end

function TT.revertmeta(::DropMissing, newdom::Domain, mcache)
  ftrans, fmcache = mcache
  TT.revertmeta(ftrans, newdom, fmcache)
end

# --------------------------------------------------

function TT.applymeta(::Sample, dom::Domain, prep)
  sinds, rinds = prep

  sdom = view(dom, sinds)
  rdom = view(dom, rinds)

  sdom, (sinds, rinds, rdom)
end

function TT.revertmeta(::Sample, newdom::Domain, mcache)
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
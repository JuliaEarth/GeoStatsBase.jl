# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    georef(table, domain)

Georeference `table` on spatial `domain`.
"""
georef(table, domain) = SpatialData(domain, table)

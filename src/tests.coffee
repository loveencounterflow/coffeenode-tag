



############################################################################################################
TYPES                     = require 'coffeenode-types'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
log                       = TRM.log.bind TRM
echo                      = TRM.echo.bind TRM
TAG 											= require '..'

tr  = TAG.new_registry()

entry_xsc = TAG.new_object  tr, 'xsc', 'extra-shapeclasses'
entry_hgv = TAG.new_object  tr, 'hgv', 'harigaya-variants'
entry_iic = TAG.new_object  tr, 'iic', 'IRGN1067R2_IICore22_MappingTable'
entry_mng = TAG.new_object  tr, 'mng', 'meanings'
entry_rj4 = TAG.new_object  tr, 'rj4', 'reform-japan-1949'
entry_rja = TAG.new_object  tr, 'rja', 'reform-japan-asahi'
entry_rc6 = TAG.new_object  tr, 'rc6', 'reform-prc-1964'

tag_FCT   = TAG.new_tag     tr, 'FCT', 'DSG:FACTORS'
tag_FRM   = TAG.new_tag     tr, 'FRM', 'DSG:FORMULA'
tag_FRQ   = TAG.new_tag     tr, 'FRQ', 'DSG:FREQUENCY'
tag_GDS   = TAG.new_tag     tr, 'GDS', 'DSG:GUIDES'
tag_MNG   = TAG.new_tag     tr, 'MNG', 'DSG:MEANINGS'
tag_SHP   = TAG.new_tag     tr, 'SHP', 'DSG:SHAPE'
tag_SMP   = TAG.new_tag     tr, 'SMP', 'DSG:SIMPLIFICATION'
tag_USG   = TAG.new_tag     tr, 'USG', 'DSG:USAGE'
tag_VAR   = TAG.new_tag     tr, 'VAR', 'DSG:VARIANT'
tag_SIM   = TAG.new_tag     tr, 'SIM', 'DSG:SIMILARITY'

log TAG.link tr, 'xsc', 'hgv', 'FCT', 'SIM'
log TAG.link tr, 'xsc', 'USG'
log TAG.link tr, 'xsc', 'USG'
log

log TRM.green entry_xsc
log TRM.green entry_hgv
log TRM.red   tag_FCT
log TRM.red   tag_SIM


log TAG.all_linked  tr, 'FCT', 'SIM', 'xsc', 'hgv'
log TAG.all_linked  tr, 'xsc', 'hgv', 'FCT', 'SIM', 'SHP'
log TAG.is_linked   tr, 'hgv', 'VAR'
log TAG.is_linked   tr, 'hgv', 'FCT'

log TAG.tags_of     tr, 'hgv'
log TAG.tags_of     tr, 'FCT'

# for id, entry of tr[ 'entry-by-id' ]
#   log TRM.rainbow entry
















############################################################################################################
assert                    = require 'assert'
assert                    = require 'assert'
#...........................................................................................................
TYPES                     = require 'coffeenode-types'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
log                       = TRM.log.bind TRM
echo                      = TRM.echo.bind TRM
#...........................................................................................................
T                         = require '..'

#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
get_sample_registry = ->
  R = T.new_registry()
  T.new_object R, 'xsc', 'extra-shapeclasses'
  T.new_object R, 'hgv', 'harigaya-variants'
  T.new_object R, 'iic', 'IRGN1067R2_IICore22_MappingTable'
  T.new_object R, 'mng', 'meanings'
  T.new_object R, 'rj4', 'reform-japan-1949'
  T.new_object R, 'rja', 'reform-japan-asahi'
  T.new_object R, 'rc6', 'reform-prc-1964'
  T.new_object R, 'rsg', 'reform-singapore'
  T.new_object R, 'rbc', 'remarks-beacons'
  T.new_object R, 'sfn', 'shape-breakdown-formula-naive'
  T.new_object R, 'sbf', 'shape-breakdown-formula'
  T.new_object R, 'sco', 'shape-constituents'
  T.new_object R, 'fth', 'shape-figural-themes'
  T.new_object R, 'sgh', 'shape-guides-hierarchy'
  T.new_object R, 'sgs', 'shape-guides-similarity'
  T.new_object R, 'sid', 'shape-similarity-identity'
  T.new_object R, 'so5', 'shape-strokeorder-zhaziwubifa'
  T.new_object R, 'uhv', 'Unihan_Variants'
  T.new_object R, 'umc', 'usage-missing-chrs'
  T.new_object R, 'uj1', 'usage-rank-ja-chubu-2050chrs-2050ranks'
  T.new_object R, 'uj2', 'usage-rank-ja-kanjicards-2500chrs-2500ranks'
  T.new_object R, 'uj3', 'usage-rank-ja-koohii-9920chrs-3250ranks'
  T.new_object R, 'uj4', 'usage-rank-ja-leedscorpus-words-2300chrs-1700ranks'
  T.new_object R, 'uc1', 'usage-rank-zhcn-leedscorpus-chrs-6800chrs-3500ranks'
  T.new_object R, 'uc2', 'usage-rank-zhcn-leedscorpus-words-1950chrs-490ranks'
  T.new_object R, 'uc3', 'usage-rank-zhcn-upennldc-words-4550chrs-1100ranks'
  T.new_object R, 'vau', 'variants-and-usage'
  T.new_tag    R, 'FCT', 'DSG:FACTORS'
  T.new_tag    R, 'FRM', 'DSG:FORMULA'
  T.new_tag    R, 'FRQ', 'DSG:FREQUENCY'
  T.new_tag    R, 'GDS', 'DSG:GUIDES'
  T.new_tag    R, 'MNG', 'DSG:MEANINGS'
  T.new_tag    R, 'SHP', 'DSG:SHAPE'
  T.new_tag    R, 'SMP', 'DSG:SIMPLIFICATION'
  T.new_tag    R, 'USG', 'DSG:USAGE'
  T.new_tag    R, 'VAR', 'DSG:VARIANT'
  T.new_tag    R, 'SIM', 'DSG:SIMILARITY'
  #.........................................................................................................
  return R


#-----------------------------------------------------------------------------------------------------------
tag_sample = ( registry ) ->
  T.tag registry, 'xsc', 'SHP', 'FCT', 'GDS'
  T.tag registry, 'hgv', 'VAR'
  T.tag registry, 'iic', 'FRQ'
  T.tag registry, 'mng', 'MNG'
  T.tag registry, 'rj4', 'SMP', 'VAR'
  T.tag registry, 'rja', 'SMP', 'VAR'
  T.tag registry, 'rc6', 'SMP', 'VAR'
  T.tag registry, 'rsg', 'SMP', 'VAR'
  T.tag registry, 'rbc', 'GDS'
  T.tag registry, 'sfn', 'SHP', 'SMP'
  T.tag registry, 'sbf', 'SHP', 'SMP'
  T.tag registry, 'sco', 'SHP', 'FCT', 'GDS'
  T.tag registry, 'fth', 'SHP'

#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@make_registry = ( test ) ->
  assert.equal ( TYPES.type_of T.new_registry() ), 'TAGTOOL/registry'
  #.........................................................................................................
  test.done()

#-----------------------------------------------------------------------------------------------------------
@make_object = ( test ) ->
  tr          = T.new_registry()
  attributes  = some: 'value'
  object      = T.new_object tr, 'myid', 'my name', attributes
  assert.equal ( TYPES.type_of object ), 'TAGTOOL/object'
  assert.equal object[ 'id' ], 'myid'
  assert.equal object[ 'name' ], 'my name'
  assert.deepEqual object[ 'attributes' ], attributes
  assert.notEqual  object[ 'attributes' ], attributes
  #.........................................................................................................
  test.done()

#-----------------------------------------------------------------------------------------------------------
@make_tag = ( test ) ->
  tr          = T.new_registry()
  tag         = T.new_tag tr, 'myid', 'my name'
  assert.equal ( TYPES.type_of tag ), 'TAGTOOL/tag'
  assert.equal tag[ 'id' ], 'myid'
  assert.equal tag[ 'name' ], 'my name'
  #.........................................................................................................
  test.done()

#-----------------------------------------------------------------------------------------------------------
@test_tagging = ( test ) ->
  tr          = T.new_registry()
  tag         = T.new_tag tr,     'TAGID', 'tag name'
  object      = T.new_object tr,  'OBJID', 'obj name'
  #.........................................................................................................
  count       = T.tag tr, 'TAGID', 'OBJID'
  assert.equal count, 1
  count       = T.tag tr, 'TAGID', 'OBJID'
  assert.equal count, 0
  assert.deepEqual ( T.tids_of tr, 'OBJID' ), [ 'TAGID', ]
  # log TRM.steel T.ids_of tr, 'OBJID'
  assert.deepEqual ( T.tids_of tr, 'OBJID' ), T.ids_of tr, 'OBJID'
  assert.deepEqual ( T.oids_of tr, 'TAGID' ), [ 'OBJID', ]
  assert.deepEqual ( T.oids_of tr, 'TAGID' ), T.ids_of tr, 'TAGID'
  assert.throws ( -> T.oids_of tr, 'OBJID' ), /tag count doesn't match probe '\+' in \[ 'OBJID' \]/
  assert.throws ( -> T.tids_of tr, 'TAGID' ), /tag count doesn't match probe '-' in \[ 'TAGID' \]/
  #.........................................................................................................
  test.done()

# #-----------------------------------------------------------------------------------------------------------
# @test_all = ->
#   TR
#   #.........................................................................................................
#   test.done()

f = ->

  log T.link tr, 'xsc', 'hgv', 'FCT', 'SIM'
  log T.link tr, 'xsc', 'USG'
  log T.link tr, 'xsc', 'USG'
  log

  log TRM.green entry_xsc
  log TRM.green entry_hgv
  log TRM.red   tag_FCT
  log TRM.red   tag_SIM


  log T.all_tagged  tr, 'FCT', 'SIM', 'xsc', 'hgv'
  log T.all_tagged  tr, 'xsc', 'hgv', 'FCT', 'SIM', 'SHP'
  log T.is_tagged   tr, 'hgv', 'VAR'
  log T.is_tagged   tr, 'hgv', 'FCT'

  log T.tids_of     tr, 'hgv'
  log T.tids_of     tr, 'FCT'

  # for id, entry of tr[ 'entry-by-id' ]
  #   log TRM.rainbow entry


############################################################################################################
# async_testing @main

# test = done: ->



# tr = get_sample_registry()
# tag_sample tr
# # log tr
# assert.throws ( -> T.tids_of tr, 'FCT' ), /tag count doesn't match probe '-' in \[ 'FCT' \]/
# log TRM.gold T.tids_of tr, 'rsg'
# log TRM.gold T.tids_of tr, 'sco'
# log TRM.gold T.oids_of tr, 'VAR'
# log TRM.gold T.oids_of tr, 'VAR', 'SMP'
# log TRM.gold T.ids_of  tr, 'VAR', 'SMP', 'sco'

# log()
# for group in T.objects_of tr, 'VAR', 'SMP'
#   log TRM.gold group

#           | objects
#           |
#      tags | a b c d e f
#     ------+-------------
#         A |       x
#         B | x   x     x
#         C | x x
#         D |     x   x
#         E |           x

# """

#             A B C D E                       a b c d e f
# tag_state:            =         obj_state:              =
# tag_state:    +       +B        obj_state:  *   *     * *acf
# tag_state:    #       = B       obj_state:  #   #     # =acf
# tag_state:      +     +C        obj_state:  * *         *ab
# tag_state:    # #     =         obj_state:  # # #     # =abcf
# tag_state:                      obj_state:          +   +e
# tag_state:    # #     =         obj_state:  # # #   # # =abcef
# tag_state:    -       -B        obj_state:  /   /     / /acf
# tag_state:      #     =C        obj_state:  # #     #   =abe

# """

# association_matrix: { ..., B: { a: x, c: x, f: x, }, ... }


T = @
t = T.new_registry()
# for tag in 'ABCDEF'
#   T.new_tag t, tag
# log TRM.green T.is_known_tag t, 'F'
# log TRM.red   T.is_known_tag t, 'G'
# log TRM.steel t
# T.tag t, 'a', 'B'
# T.tag t, 'a', 'C'
# log TRM.yellow t
# log TRM.green T.has_tag t, 'a', 'B'
# log TRM.red   T.has_tag t, 'a', 'D'
# log TRM.gold T.tags_of t, 'a'
# log TRM.gold T.tags_of t, 'b'


tags_and_oids = [
  [ 'A', 'd',    ]
  [ 'B', 'acf',  ]
  [ 'C', 'ab',   ]
  [ 'D', 'ce',   ]
  [ 'E', 'f',    ]
  ]

for [ tag, oids, ] in tags_and_oids
  log TRM.yellow tag, oids
  T.new_tag t, tag
  for oid in oids
    T.tag t, oid, tag

log TRM.rainbow t

s = T.new_state t

show = ( t, s ) ->
  log ( TRM.cyan ( x for x of s[ 'oids' ] ).sort().join '' ), ( TRM.pink ( x for x of s[ 'tags' ] ).sort().join '' )

log TRM.lime T.select t, s, null, 'B'
show t, s
log TRM.lime T.select t, s, null, 'C'
show t, s
log TRM.lime T.select t, s, 'e', null
show t, s
log TRM.lime T.deselect t, s, null, 'B'
show t, s
for tag in 'abcdef'
  log tag if T.is_selected t, s, tag
for oid in 'ABCDEF'
  log oid if T.is_selected t, s, oid







############################################################################################################
TYPES                     = require 'coffeenode-types'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
log                       = TRM.log.bind TRM
echo                      = TRM.echo.bind TRM
assert                    = require 'assert'

#-----------------------------------------------------------------------------------------------------------
misfit = {}

#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
equals = ( a, b ) ->
  try
    assert.deepEqual a, b
    return true
  catch error
    return false

#-----------------------------------------------------------------------------------------------------------
is_subset_of = ( a, b ) ->
  switch type_of_a = TYPES.type_of a
    when 'pod'
      unless ( type_of_b = TYPES.type_of b ) is type_of_a
        throw new Error "type mismatch: can't compare a #{type_of_a} with a #{type_of_b}"
      for k, v of a
        return false if ( not b[ k ]? ) or v isnt b[ k ]
      return true
    else
      throw new Error "unable to determine subsets of value of type #{type_of_a}"

#===========================================================================================================
# OBJECT CREATION
#-----------------------------------------------------------------------------------------------------------
@new_registry = ->
  R =
    '~isa':         'TAGTOOL/registry'
    ### keys are tags, values are `{ $oid: 1, }` facets: ###
    'tags':         {}
    # ...
    # 'rules':        {}
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_tag = ( me, tag ) ->
  throw new Error "tag #{rpr tag} already registered" if @is_known_tag me, tag
  me[ 'tags' ][ tag ] = {}
  #.........................................................................................................
  return me

#-----------------------------------------------------------------------------------------------------------
@new_state = ( me ) ->
  ### Given a `TAGTOOL/registry`, a list of OIDs and a list of tags, return a state object that records
  the selection status. All tags named must be known to the registry; OIDs are arbitrary. ###
  #.........................................................................................................
  R =
    '~isa':           'TAGTOOL/state'
    'tags':           {}
    'oids':           {}
    'implicit-tags':  {}
    # 'implicit-oids':  {}
  #.........................................................................................................
  return R


#===========================================================================================================
# TAGGING
#-----------------------------------------------------------------------------------------------------------
@tag = ( me, oid, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  target = me[ 'tags' ][ tag ]
  #.........................................................................................................
  unless target[ oid ]?
    target[ oid ] = 1
    return 1
  #.........................................................................................................
  return 0

#-----------------------------------------------------------------------------------------------------------
@untag = ( me, oid, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  target = me[ 'tags' ][ tag ]
  #.........................................................................................................
  if target[ oid ]?
    delete target[ oid ]
    return 1
  #.........................................................................................................
  return 0


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@is_known_tag = ( me, tag ) ->
  return me[ 'tags' ][ tag ]?

#-----------------------------------------------------------------------------------------------------------
@is_known_oid = ( me, oid ) ->
  return ( @_get_all_oids me )[ oid ]?

#-----------------------------------------------------------------------------------------------------------
@has_tag = ( me, oid, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  #.........................................................................................................
  return me[ 'tags' ][ tag ][ oid ]?

#-----------------------------------------------------------------------------------------------------------
@tags_of = ( me, oid ) ->
  return ( tag for tag of @_tags_of me, oid )

#-----------------------------------------------------------------------------------------------------------
@_tags_of = ( me, oid ) ->
  if oid?
    R = {}
    for tag, oids of me[ 'tags' ]
      R[ tag ] = 1 if oids[ oid ]?
    return R
  #.........................................................................................................
  return me[ 'tags' ]

#-----------------------------------------------------------------------------------------------------------
@oids_of = ( me, tag = null ) ->
  if tag?
    throw new Error "unknown tag #{rpr tag}" unless ( oids = me[ 'tags' ][ tag ] )?
    return ( oid for oid of oids )
  #.........................................................................................................
  return ( oid for oid of @_get_all_oids me )

#-----------------------------------------------------------------------------------------------------------
@_get_all_oids = ( me ) ->
  return ( @_get_all_oids_and_max_oid_count me )[ 0 ]

#-----------------------------------------------------------------------------------------------------------
@_get_all_oids_and_max_oid_count = ( me ) ->
  all_oids      = {}
  max_oid_count = 0
  for tag, oids of me[ 'tags' ]
    local_count = 0
    for oid of oids
      all_oids[ oid ]   = 1
      local_count      += 1
    max_oid_count = Math.max max_oid_count, local_count
  #.........................................................................................................
  return [ all_oids, max_oid_count, ]

#-----------------------------------------------------------------------------------------------------------
@get_max_oid_count = ( me ) ->
  return ( @_get_all_oids_and_max_oid_count me )[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@get_max_tag_count = ( me ) ->
  R = 0
  #.........................................................................................................
  for oid in @oids_of me
    R = Math.max R, ( @tags_of me, oid ).length
  #.........................................................................................................
  return R


#===========================================================================================================
# STATE, SELECT, DESELECT
# #-----------------------------------------------------------------------------------------------------------
# @select = ( me, state, hints... ) ->

# #-----------------------------------------------------------------------------------------------------------
# @deselect = ( me, state, oids, tags ) ->

#-----------------------------------------------------------------------------------------------------------
@select_tag = ( me, state, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  #.........................................................................................................
  R = 0
  #.........................................................................................................
  ### Update state if tag is not already selected: ###
  unless state[ 'tags' ][ tag ]?
    state[ 'tags' ][ tag ]  = 1
    R                      += 1
  #.........................................................................................................
  ### Select all those OIDs that are tagged with this tag: ###
  selected_oids = state[ 'oids' ]
  for oid of me[ 'tags' ][ tag ]
    continue if selected_oids[ oid ]?
    selected_oids[ oid ]  = 1
    R                    += 1
  #.........................................................................................................
  @_select_implicit_tags me, state
  return R

#-----------------------------------------------------------------------------------------------------------
@deselect_tag = ( me, state, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  #.........................................................................................................
  R = 0
  #.........................................................................................................
  ### Update state if tag is selected: ###
  if state[ 'tags' ][ tag ]?
    delete state[ 'tags' ][ tag ]
    R += 1
  #.........................................................................................................
  ### Deselect all those OIDs that are not tagged with another selected tag: ###
  selected_oids = state[ 'oids' ]
  for oid of me[ 'tags' ][ tag ]
    continue unless selected_oids[ oid ]?
    has_tag = no
    for oid_tag of @_tags_of me, oid
      continue unless state[ 'tags' ][ oid_tag ]?
      has_tag = yes
      break
    unless has_tag
      delete selected_oids[ oid ]
      R += 1
  #.........................................................................................................
  R += @_deselect_implicit_tags me, state
  return R

#-----------------------------------------------------------------------------------------------------------
@_select_implicit_tags = ( me, state ) ->
  ### Implicit-select all those tags that have all their OIDs selected: ###
  selected_oids = state[ 'oids' ]
  for tag, tagged_oids of me[ 'tags' ]
    continue if state[ 'tags' ][ tag ]?
    continue unless is_subset_of tagged_oids, selected_oids
    state[ 'implicit-tags' ][ tag ]  = 1
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_deselect_implicit_tags = ( me, state ) ->
  ### Implicit-deselect all those tags that do not have all their OIDs selected: ###
  selected_oids = state[ 'oids' ]
  for tag of state[ 'implicit-tags' ]
    has_selected_tag = no
    for oid of me[ 'tags' ][ tag ]
      continue if state[ 'oids' ][ oid ]?
      delete state[ 'implicit-tags' ][ tag ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@select_oid = ( me, state, oid ) ->
  throw new Error "unknown oid #{rpr oid}" unless @is_known_oid me, oid
  return 0 if state[ 'oids' ][ oid ]?
  state[ 'oids' ][ oid ] = 1
  return 1 + @_select_implicit_tags me, state

#-----------------------------------------------------------------------------------------------------------
@get_selected_oids = ( me, state ) ->
  return ( oid for oid of state[ 'oids' ] )

# #-----------------------------------------------------------------------------------------------------------
# @is_selected = ( me, state, hint ) ->
#   group_name = if @is_known_tag me, hint then 'tags' else 'oids'
#   return state[ group_name ][ hint ]?


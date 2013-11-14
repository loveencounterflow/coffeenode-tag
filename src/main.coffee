



#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
misfit  = {}
rpr     = JSON.stringify

#-----------------------------------------------------------------------------------------------------------
pod_is_subset_of = ( a, b ) ->
  for k, v of a
    return false if ( not b[ k ]? ) or v isnt b[ k ]
  return true


#===========================================================================================================
# OBJECT CREATION
#-----------------------------------------------------------------------------------------------------------
@new_registry = ->
  R =
    '~isa':         'TAGTOOL/registry'
    ### keys are tags, values are `{ $oid: 1, }` facets: ###
    '%oids':        {}
    'tags':         {}
    'state':        null
    # 'rules':        {}
  #.........................................................................................................
  R[ 'state' ] = @_new_state R
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_tag = ( me, tag ) ->
  throw new Error "tag #{rpr tag} already registered" if @is_known_tag me, tag
  me[ 'tags' ][ tag ] = {}
  #.........................................................................................................
  return me

#-----------------------------------------------------------------------------------------------------------
@_new_state = ( me ) ->
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
    me[ '%oids' ][ oid ]  = 1
    target[ oid ]         = 1
    return 1 + @_update_tag_selection me, tag
  #.........................................................................................................
  return 0

#-----------------------------------------------------------------------------------------------------------
@untag = ( me, oid, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  target = me[ 'tags' ][ tag ]
  #.........................................................................................................
  if target[ oid ]?
    delete target[ oid ]
    return 1 + @_update_tag_selection me, tag
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
  return me[ '%oids' ]

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
# @select = ( me, hints... ) ->

# #-----------------------------------------------------------------------------------------------------------
# @deselect = ( me, oids, tags ) ->

#-----------------------------------------------------------------------------------------------------------
@select_tag = ( me, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  #.........................................................................................................
  R     = 0
  state = me[ 'state' ]
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
  @_select_implicit_tags me
  return R

#-----------------------------------------------------------------------------------------------------------
@deselect_tag = ( me, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  #.........................................................................................................
  R     = 0
  state = me[ 'state' ]
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
  R += @_deselect_implicit_tags me
  return R

#-----------------------------------------------------------------------------------------------------------
@select_oid = ( me, oid ) ->
  throw new Error "unknown oid #{rpr oid}" unless @is_known_oid me, oid
  state = me[ 'state' ]
  return 0 if state[ 'oids' ][ oid ]?
  state[ 'oids' ][ oid ] = 1
  return 1 + @_select_implicit_tags me

#-----------------------------------------------------------------------------------------------------------
@deselect_oid = ( me, oid ) ->
  throw new Error "unknown oid #{rpr oid}" unless @is_known_oid me, oid
  state = me[ 'state' ]
  return 0 unless state[ 'oids' ][ oid ]?
  delete state[ 'oids' ][ oid ]
  return 1 + @_deselect_implicit_tags me

#-----------------------------------------------------------------------------------------------------------
@_select_implicit_tags = ( me ) ->
  ### Implicit-select all those tags that have all their OIDs selected: ###
  state         = me[ 'state' ]
  selected_oids = state[ 'oids' ]
  #.........................................................................................................
  for tag, tagged_oids of me[ 'tags' ]
    if state[ 'tags' ][ tag ]?
      delete state[ 'implicit-tags' ][ tag ]
      continue
    continue unless pod_is_subset_of tagged_oids, selected_oids
    state[ 'implicit-tags' ][ tag ]  = 1
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_deselect_implicit_tags = ( me ) ->
  ### Implicit-deselect all those tags that do not have all their OIDs selected: ###
  state         = me[ 'state' ]
  selected_oids = state[ 'oids' ]
  #.........................................................................................................
  for tag of state[ 'implicit-tags' ]
    has_selected_tag = no
    for oid of me[ 'tags' ][ tag ]
      continue if state[ 'oids' ][ oid ]?
      delete state[ 'implicit-tags' ][ tag ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_update_tag_selection = ( me, tag ) ->
  return if @is_selected_tag me, tag then @select_tag me, tag else @deselect_tag me, tag

#-----------------------------------------------------------------------------------------------------------
@get_selected_oids = ( me ) ->
  return ( oid for oid of state[ 'oids' ] )

#-----------------------------------------------------------------------------------------------------------
@is_selected_tag = ( me, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  state = me[ 'state' ]
  return state[ 'tags' ][ tag ]?

#-----------------------------------------------------------------------------------------------------------
@is_implicitly_selected_tag = ( me, tag ) ->
  throw new Error "unknown tag #{rpr tag}" unless @is_known_tag me, tag
  state = me[ 'state' ]
  return state[ 'implicit-tags' ][ tag ]?

#-----------------------------------------------------------------------------------------------------------
@is_selected_oid = ( me, oid ) ->
  throw new Error "unknown oid #{rpr oid}" unless @is_known_oid me, oid
  state = me[ 'state' ]
  return state[ 'oids' ][ oid ]?

#-----------------------------------------------------------------------------------------------------------
@clear_selection = ( me ) ->
  state = me[ 'state' ]
  delete state[ 'tags'          ][ tag ] for tag of state[ 'tags'          ]
  delete state[ 'implicit-tags' ][ tag ] for tag of state[ 'implicit-tags' ]
  delete state[ 'oids'          ][ oid ] for oid of state[ 'oids'          ]
  return null



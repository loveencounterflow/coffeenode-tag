



############################################################################################################
TYPES                     = require 'coffeenode-types'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
log                       = TRM.log.bind TRM
echo                      = TRM.echo.bind TRM


#-----------------------------------------------------------------------------------------------------------
misfit = {}

#-----------------------------------------------------------------------------------------------------------
@new_registry = ->
  R =
    '~isa':           'TAGTOOL/registry'
    'entry-by-id':    {}
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_register = ( me, entry ) ->
  id = entry[ 'id' ]
  throw new Error "entry with ID #{rpr id} already registered" if me[ 'entry-by-id' ][ id ]?
  me[ 'entry-by-id' ][ id ] = entry
  return null

#-----------------------------------------------------------------------------------------------------------
@new_tag = ( me, id, name, rules ) ->
  R =
    '~isa':       'TAGTOOL/tag'
    'id':         id
    'name':       name
    'rules':      rules ? {}
    'oids':       {}
  #.........................................................................................................
  @_register me, R
  return R

#-----------------------------------------------------------------------------------------------------------
@new_object = ( me, id, name, attributes ) ->
  attributes_ = {}
  ( attributes_[ key ] = value for key, value of attributes ) if attributes?
  R =
    '~isa':       'TAGTOOL/object'
    'id':         id
    'name':       name
    'attributes': attributes_
    'tids':       {}
  #.........................................................................................................
  @_register me, R
  return R

#-----------------------------------------------------------------------------------------------------------
@tag = ( me, ids... ) ->
  [ objects, tags, ]  = @_get_objects_and_tags me, ids, '+', '+'
  link_count          = 0
  #.........................................................................................................
  for tag in tags
    for object in objects
      link_count += @_tag me, object, tag
  #.........................................................................................................
  return link_count

#-----------------------------------------------------------------------------------------------------------
@_tag = ( me, object, tag ) ->
  return 0 if tag[ 'oids' ][ object[ 'id' ] ]?
  tag[    'oids' ][ object[ 'id' ] ] = 1
  object[ 'tids' ][    tag[ 'id' ] ] = 1
  return 1

#-----------------------------------------------------------------------------------------------------------
@_untag = ( me, oids... ) ->
  return 0 unless tag[ 'oids' ][ object[ 'id' ] ]?
  my_id         = me[ 'id' ]
  my_entry_ids  = me[ 'entry-ids' ]
  for entry in oids
    delete my_entry_ids[ entry[ 'id' ] ]
    delete entry[ 'tids' ][ my_id ]

#-----------------------------------------------------------------------------------------------------------
@has_tag = ( me, oid, tid ) ->
  entries = @_get_objects_and_tags me, oid, tid
  return @_has_tag me, entries[ 0 ][ 0 ], entries[ 1 ][ 0 ]

#-----------------------------------------------------------------------------------------------------------
@_has_tag = ( me, object, tag ) ->
  if tag?
    try
      return object[ 'tids' ][ tag[ 'id' ] ]?
    catch error
      throw error
  else
    return object[ 'tids' ].length isnt 0

#-----------------------------------------------------------------------------------------------------------
@all_have_tag = ( me, ids... ) ->
  [ objects, tags, ] = @_get_objects_and_tags me, ids, '+', '+'
  #.........................................................................................................
  for tag in tags
    for object in objects
      return false unless @_has_tag me, object, tag
  #.........................................................................................................
  return true

#-----------------------------------------------------------------------------------------------------------
@any_have_tag = ( me, ids... ) ->
  [ objects, tags, ] = @_get_objects_and_tags me, ids, '+', '+'
  #.........................................................................................................
  for tag in tags
    for object in objects
      return true if @_has_tag me, object, tag
  #.........................................................................................................
  return false

#-----------------------------------------------------------------------------------------------------------
@get = ( me, id, fallback = misfit ) ->
  return @_get me, id, null, fallback

#-----------------------------------------------------------------------------------------------------------
@_get = ( me, id, type, fallback ) ->
  R = me[ 'entry-by-id' ][ id ]
  if R?
    TYPES.validate R, type if type?
  else
    return fallback unless fallback is misfit
    throw new Error "unknown ID #{rpr id}"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@get_object = ( me, id, fallback = misfit ) ->
  R = @get me, id
  unless R is misfit or ( type = TYPES.type_of R ) is 'TAGTOOL/object'
    throw new Error "entry with ID #{rpr id} is a #{type}, not a TAGTOOL/object"
  return R

#-----------------------------------------------------------------------------------------------------------
@get_tag = ( me, id, fallback = misfit ) ->
  R = @get me, id
  unless R is misfit or ( type = TYPES.type_of R ) is 'TAGTOOL/tag'
    throw new Error "entry with ID #{rpr id} is a #{type}, not a TAGTOOL/tag"
  return R

#-----------------------------------------------------------------------------------------------------------
@ids_of = ( me, ids... ) ->
  return ( id for id of me[ 'entry-by-id' ] ) if ids.length is 0
  entries = ( @get me, id for id in ids )
  return ( id for id of @_ids_of me, entries )

#-----------------------------------------------------------------------------------------------------------
@_ids_of = ( me, entries ) ->
  # could use `Object.keys`
  R = {}
  for entry in entries
    switch ( type = TYPES.type_of entry )
      when 'TAGTOOL/tag'    then property_name = 'oids'
      when 'TAGTOOL/object' then property_name = 'tids'
      else throw new Error "unable to get IDs from value of type #{rpr type}"
    for id of entry[ property_name ]
      R[ id ] = 1
  # log TRM.pink '©33e', R
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@tids_of = ( me, oids... ) ->
  [ objects, ignored, ]  = @_get_objects_and_tags me, oids, '+', '-'
  return ( tid for tid of @_tids_of me, objects )

#-----------------------------------------------------------------------------------------------------------
@_tids_of = ( me, objects ) ->
  R = {}
  #.........................................................................................................
  for object in objects
    for tid of object[ 'tids' ]
      R[ tid ] = 1
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@oids_of = ( me, oids... ) ->
  [ ignored, tags, ]  = @_get_objects_and_tags me, oids, '-', '+'
  return ( oid for oid of @_oids_of me, tags )

#-----------------------------------------------------------------------------------------------------------
@_oids_of = ( me, tags ) ->
  R = {}
  #.........................................................................................................
  for tag in tags
    for oid of tag[ 'oids' ]
      R[ oid ] = 1
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_get_objects_and_tags = ( me, ids, object_probe, tag_probe ) ->
  entry_by_id = me[ 'entry-by-id' ]
  tags        = []
  objects     = []
  R           = [ objects, tags, ]
  #.........................................................................................................
  for id in ids
    entry = entry_by_id[ id ]
    throw new Error "unknown ID #{rpr id}" unless entry?
    #.......................................................................................................
    switch type = TYPES.type_of entry
      #.....................................................................................................
      when 'TAGTOOL/tag'
        tags.push entry
      #.....................................................................................................
      when 'TAGTOOL/object'
        objects.push entry
      #.....................................................................................................
      else
        throw new Error "unable to handle value of type #{rpr type}"
  #.........................................................................................................
  unless _match tags.length, tag_probe
    throw new Error "tag count doesn't match probe #{rpr tag_probe} in #{rpr ids}"
  unless _match objects.length, object_probe
    throw new Error "object count doesn't match probe #{rpr object_probe} in #{rpr ids}"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
_match = ( n, probe ) ->
  return true unless probe
  switch probe
    when '+' then return n >  0
    when '*' then return n >= 0
    when '-' then return n == 0
    else
      n = parseInt n, 10
      throw new Error "illegal probe: #{rpr n}" unless TYPES.isa_number n
      return true if n == probe






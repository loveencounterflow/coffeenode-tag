

- [CoffeeNode TagTool](#coffeenode-tagtool)
	- [Installation](#installation)
	- [Usage](#usage)
	- [](#)
	- [API](#api)
		- [Object Creation](#object-creation)
			- [`@new_registry = ->`](#@new_registry-=-->)
			- [`@register_tag = ( me, tag ) ->`](#@register_tag-=--me-tag--->)
		- [Tagging](#tagging)
			- [`@tag = ( me, oid, tag ) ->`](#@tag-=--me-oid-tag--->)
			- [`@untag = ( me, oid, tag ) ->`](#@untag-=--me-oid-tag--->)
			- [`@tags_of = ( me, oid = null ) ->`](#@tags_of-=--me-oid-=-null--->)
			- [`@has_tag = ( me, oid, tag ) ->`](#@has_tag-=--me-oid-tag--->)
			- [`@oids_of = ( me, tag = null ) ->`](#@oids_of-=--me-tag-=-null--->)
			- [`@is_known_tag = ( me, tag ) ->`](#@is_known_tag-=--me-tag--->)
			- [`@is_known_oid = ( me, oid ) ->`](#@is_known_oid-=--me-oid--->)
			- [`@get_max_tag_count = ( me ) ->`](#@get_max_tag_count-=--me--->)
			- [`@get_max_oid_count = ( me ) ->`](#@get_max_oid_count-=--me--->)
		- [Selecting & Deselecting](#selecting-&-deselecting)
			- [`@select_tag = ( me, tag ) ->`](#@select_tag-=--me-tag--->)
			- [`@deselect_tag = ( me, tag ) ->`](#@deselect_tag-=--me-tag--->)
			- [`@select_oid = ( me, oid ) ->`](#@select_oid-=--me-oid--->)
			- [`@deselect_oid = ( me, oid ) ->`](#@deselect_oid-=--me-oid--->)
			- [`@clear_selection = ( me ) ->`](#@clear_selection-=--me--->)
			- [`@get_selected_oids = ( me ) ->`](#@get_selected_oids-=--me--->)
			- [`@is_implicitly_selected_tag = ( me, tag ) ->`](#@is_implicitly_selected_tag-=--me-tag--->)
			- [`@is_selected_oid = ( me, oid ) ->`](#@is_selected_oid-=--me-oid--->)
			- [`@is_selected_tag = ( me, tag ) ->`](#@is_selected_tag-=--me-tag--->)
		- [Private Methods](#private-methods)
			- [`@_deselect_implicit_tags = ( me ) ->`](#@_deselect_implicit_tags-=--me--->)
			- [`@_get_all_oids = ( me ) ->`](#@_get_all_oids-=--me--->)
			- [`@_get_all_oids_and_max_oid_count = ( me ) ->`](#@_get_all_oids_and_max_oid_count-=--me--->)
			- [`@_new_state = ( me ) ->`](#@_new_state-=--me--->)
			- [`@_select_implicit_tags = ( me ) ->`](#@_select_implicit_tags-=--me--->)
			- [`@_tags_of = ( me, oid ) ->`](#@_tags_of-=--me-oid--->)
			- [`@_update_tag_selection = ( me, tag ) ->`](#@_update_tag_selection-=--me-tag--->)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


CoffeeNode TagTool
============================================================================================================

A simple in-memory tagging library.

## Installation

    npm install coffeenode-tagtool
    TAGTOOL = require 'coffeenode-tagtool'

## Usage

Tags must be registered before their first use; object IDs (OIDs) are registered implicitly by associating
them with tags.

------------------------

<!-- ################################################################################################### -->
## API

> **Note**: below, `@` represents the TagTool library, and `me` a TagTool Registry.

<!-- =================================================================================================== -->
### Object Creation

#### `@new_registry = ->`

Create a new tag registry; the Plain Old Object (POD) that is returned has the format

    registry =
      '~isa':         'TAGTOOL/registry'
      '%oids':        {}      # cache; keys are OIDs; all values are 1
      'tags':         {}      # keys are tags; values are PODs whose keys are OIDs and whose values are 1
      'state':        null    # result of calling `@_new_state`


#### `@register_tag = ( me, tag ) ->`

Register a new tag in the library.


<!-- =================================================================================================== -->
### Tagging

#### `@tag = ( me, oid, tag ) ->`
#### `@untag = ( me, oid, tag ) ->`

Associate or disassociate a given OID and tag.

#### `@tags_of = ( me, oid = null ) ->`

Returns all the tags a given OID is associated with; if no OID is given, return a list of all registered
tags in the given registry.

#### `@has_tag = ( me, oid, tag ) ->`

Return whether the given OID is associated with the given tag.

#### `@oids_of = ( me, tag = null ) ->`

Return all the OIDs that the given tag is associated with; if no tag is given, return a list of all the
OIDs known to the given registry.

#### `@is_known_tag = ( me, tag ) ->`
#### `@is_known_oid = ( me, oid ) ->`

Return whether a given tag or OID is known to the given registry.

#### `@get_max_tag_count = ( me ) ->`
#### `@get_max_oid_count = ( me ) ->`

<!-- =================================================================================================== -->
### Selecting & Deselecting

#### `@select_tag = ( me, tag ) ->`
#### `@deselect_tag = ( me, tag ) ->`

Select or deselect the given tag. When a tag is selected, all the OIDs associated with that tag will
likewise get selected; conversely, when a tag is deselected, all the OIDs that not associated with any other
selected tag will get deselected. Example:

```coffeescript
trg = TT.new_registry()
TT.new_tag      trg, 'fruit'
TT.new_tag      trg, 'domestic'
TT.new_tag      trg, 'exotic'
TT.new_tag      trg, 'sweet'
TT.new_tag      trg, 'sour'
TT.tag          trg, 'Apple',     'fruit'
TT.tag          trg, 'Apple',     'domestic'
TT.tag          trg, 'Apple',     'sweet'
TT.tag          trg, 'Pineapple', 'fruit'
TT.tag          trg, 'Pineapple', 'exotic'
TT.tag          trg, 'Pineapple', 'sour'

TT.select_tag   trg, 'fruit'  # selects also OIDs `Apple` and `Pineapple`

TT.select_tag   trg, 'sweet'  # `Apple` is already selected, so no change

TT.deselect_tag trg, 'fruit'  # `Pineapple` gets deselected, but as `Apple` is tagged `sweet` and `sweet`
                              # is still selected, `Apple` stays selected.
```

#### `@select_oid = ( me, oid ) ->`
#### `@deselect_oid = ( me, oid ) ->`

Select or deselect the given OID. When

#### `@clear_selection = ( me ) ->`

#### `@get_selected_oids = ( me ) ->`

#### `@is_implicitly_selected_tag = ( me, tag ) ->`
#### `@is_selected_oid = ( me, oid ) ->`
#### `@is_selected_tag = ( me, tag ) ->`

<!-- =================================================================================================== -->
### Private Methods

#### `@_deselect_implicit_tags = ( me ) ->`


#### `@_get_all_oids = ( me ) ->`


#### `@_get_all_oids_and_max_oid_count = ( me ) ->`


#### `@_new_state = ( me ) ->`

Given a `TAGTOOL/registry`, return a state object to record the selection status.

#### `@_select_implicit_tags = ( me ) ->`


#### `@_tags_of = ( me, oid ) ->`


#### `@_update_tag_selection = ( me, tag ) ->`




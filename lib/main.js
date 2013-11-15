(function() {
  var misfit, pod_is_subset_of, rpr;

  misfit = {};

  rpr = JSON.stringify;

  pod_is_subset_of = function(a, b) {
    var k, v;
    for (k in a) {
      v = a[k];
      if ((b[k] == null) || v !== b[k]) {
        return false;
      }
    }
    return true;
  };

  this.new_registry = function() {
    var R;
    R = {
      '~isa': 'TAGTOOL/registry',
      '%oids': {},
      'tags': {},
      'state': null
    };
    R['state'] = this._new_state(R);
    return R;
  };

  this.register_tag = function(me, tag) {
    if (this.is_known_tag(me, tag)) {
      throw new Error("tag " + (rpr(tag)) + " already registered");
    }
    me['tags'][tag] = {};
    return me;
  };

  this._new_state = function(me) {
    /* Given a `TAGTOOL/registry`, a list of OIDs and a list of tags, return a state object to record
    the selection status.
    */

    var R;
    R = {
      '~isa': 'TAGTOOL/state',
      'tags': {},
      'oids': {},
      'implicit-tags': {}
    };
    return R;
  };

  this.tag = function(me, oid, tag) {
    var target;
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    target = me['tags'][tag];
    if (target[oid] == null) {
      me['%oids'][oid] = 1;
      target[oid] = 1;
      return 1 + this._update_tag_selection(me, tag);
    }
    return 0;
  };

  this.untag = function(me, oid, tag) {
    var target;
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    target = me['tags'][tag];
    if (target[oid] != null) {
      delete target[oid];
      return 1 + this._update_tag_selection(me, tag);
    }
    return 0;
  };

  this.is_known_tag = function(me, tag) {
    return me['tags'][tag] != null;
  };

  this.is_known_oid = function(me, oid) {
    return (this._get_all_oids(me))[oid] != null;
  };

  this.has_tag = function(me, oid, tag) {
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    return me['tags'][tag][oid] != null;
  };

  this.tags_of = function(me, oid) {
    var tag;
    if (oid == null) {
      oid = null;
    }
    return (function() {
      var _results;
      _results = [];
      for (tag in this._tags_of(me, oid)) {
        _results.push(tag);
      }
      return _results;
    }).call(this);
  };

  this._tags_of = function(me, oid) {
    var R, oids, tag, _ref;
    if (oid != null) {
      R = {};
      _ref = me['tags'];
      for (tag in _ref) {
        oids = _ref[tag];
        if (oids[oid] != null) {
          R[tag] = 1;
        }
      }
      return R;
    }
    return me['tags'];
  };

  this.oids_of = function(me, tag) {
    var oid, oids;
    if (tag == null) {
      tag = null;
    }
    if (tag != null) {
      if ((oids = me['tags'][tag]) == null) {
        throw new Error("unknown tag " + (rpr(tag)));
      }
      return (function() {
        var _results;
        _results = [];
        for (oid in oids) {
          _results.push(oid);
        }
        return _results;
      })();
    }
    return (function() {
      var _results;
      _results = [];
      for (oid in this._get_all_oids(me)) {
        _results.push(oid);
      }
      return _results;
    }).call(this);
  };

  this._get_all_oids = function(me) {
    return me['%oids'];
  };

  this._get_all_oids_and_max_oid_count = function(me) {
    var all_oids, local_count, max_oid_count, oid, oids, tag, _ref;
    all_oids = {};
    max_oid_count = 0;
    _ref = me['tags'];
    for (tag in _ref) {
      oids = _ref[tag];
      local_count = 0;
      for (oid in oids) {
        all_oids[oid] = 1;
        local_count += 1;
      }
      max_oid_count = Math.max(max_oid_count, local_count);
    }
    return [all_oids, max_oid_count];
  };

  this.get_max_oid_count = function(me) {
    return (this._get_all_oids_and_max_oid_count(me))[1];
  };

  this.get_max_tag_count = function(me) {
    var R, oid, _i, _len, _ref;
    R = 0;
    _ref = this.oids_of(me);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      oid = _ref[_i];
      R = Math.max(R, (this.tags_of(me, oid)).length);
    }
    return R;
  };

  this.select_tag = function(me, tag) {
    var R, oid, selected_oids, state;
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    R = 0;
    state = me['state'];
    /* Update state if tag is not already selected:*/

    if (state['tags'][tag] == null) {
      state['tags'][tag] = 1;
      R += 1;
    }
    /* Select all those OIDs that are tagged with this tag:*/

    selected_oids = state['oids'];
    for (oid in me['tags'][tag]) {
      if (selected_oids[oid] != null) {
        continue;
      }
      selected_oids[ oid] = 1;
      R += 1;
    }
    this._select_implicit_tags(me);
    return R;
  };

  this.deselect_tag = function(me, tag) {
    var R, has_tag, oid, oid_tag, selected_oids, state;
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    R = 0;
    state = me['state'];
    /* Update state if tag is selected:*/

    if (state['tags'][tag] != null) {
      delete state['tags'][tag];
      R += 1;
    }
    /* Deselect all those OIDs that are not tagged with another selected tag:*/

    selected_oids = state['oids'];
    for (oid in me['tags'][tag]) {
      if (selected_oids[oid] == null) {
        continue;
      }
      has_tag = false;
      for (oid_tag in this._tags_of(me, oid)) {
        if (state['tags'][oid_tag] == null) {
          continue;
        }
        has_tag = true;
        break;
      }
      if (!has_tag) {
        delete selected_oids[ oid];
        R += 1;
      }
    }
    R += this._deselect_implicit_tags(me);
    return R;
  };

  this.select_oid = function(me, oid) {
    var state;
    if (!this.is_known_oid(me, oid)) {
      throw new Error("unknown oid " + (rpr(oid)));
    }
    state = me['state'];
    if (state['oids'][oid] != null) {
      return 0;
    }
    state['oids'][oid] = 1;
    return 1 + this._select_implicit_tags(me);
  };

  this.deselect_oid = function(me, oid) {
    var state;
    if (!this.is_known_oid(me, oid)) {
      throw new Error("unknown oid " + (rpr(oid)));
    }
    state = me['state'];
    if (state['oids'][oid] == null) {
      return 0;
    }
    delete state['oids'][oid];
    return 1 + this._deselect_implicit_tags(me);
  };

  this._select_implicit_tags = function(me) {
    /* Implicit-select all those tags that have all their OIDs selected:*/

    var selected_oids, state, tag, tagged_oids, _ref;
    state = me['state'];
    selected_oids = state['oids'];
    _ref = me['tags'];
    for (tag in _ref) {
      tagged_oids = _ref[tag];
      if (state['tags'][tag] != null) {
        delete state['implicit-tags'][tag];
        continue;
      }
      if (!pod_is_subset_of(tagged_oids, selected_oids)) {
        continue;
      }
      state['implicit-tags'][tag] = 1;
    }
    return null;
  };

  this._deselect_implicit_tags = function(me) {
    /* Implicit-deselect all those tags that do not have all their OIDs selected:*/

    var has_selected_tag, oid, selected_oids, state, tag;
    state = me['state'];
    selected_oids = state['oids'];
    for (tag in state['implicit-tags']) {
      has_selected_tag = false;
      for (oid in me['tags'][tag]) {
        if (state['oids'][oid] != null) {
          continue;
        }
        delete state['implicit-tags'][tag];
      }
    }
    return null;
  };

  this._update_tag_selection = function(me, tag) {
    if (this.is_selected_tag(me, tag)) {
      return this.select_tag(me, tag);
    } else {
      return this.deselect_tag(me, tag);
    }
  };

  this.get_selected_oids = function(me) {
    var oid;
    return (function() {
      var _results;
      _results = [];
      for (oid in state['oids']) {
        _results.push(oid);
      }
      return _results;
    })();
  };

  this.is_selected_tag = function(me, tag) {
    var state;
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    state = me['state'];
    return state['tags'][tag] != null;
  };

  this.is_implicitly_selected_tag = function(me, tag) {
    var state;
    if (!this.is_known_tag(me, tag)) {
      throw new Error("unknown tag " + (rpr(tag)));
    }
    state = me['state'];
    return state['implicit-tags'][tag] != null;
  };

  this.is_selected_oid = function(me, oid) {
    var state;
    if (!this.is_known_oid(me, oid)) {
      throw new Error("unknown oid " + (rpr(oid)));
    }
    state = me['state'];
    return state['oids'][oid] != null;
  };

  this.clear_selection = function(me) {
    var oid, state, tag;
    state = me['state'];
    for (tag in state['tags']) {
      delete state['tags'][tag];
    }
    for (tag in state['implicit-tags']) {
      delete state['implicit-tags'][tag];
    }
    for (oid in state['oids']) {
      delete state['oids'][oid];
    }
    return null;
  };

}).call(this);
/****generated by https://github.com/loveencounterflow/larq****/
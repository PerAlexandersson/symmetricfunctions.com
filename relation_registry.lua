-- Registry for structured relation rows inside polydata blocks.

local M = {}

local function trim(s)
  return tostring(s or ""):match("^%s*(.-)%s*$")
end

local function normalize_key(key)
  return trim(key):lower():gsub("%s+", " ")
end

local function normalize_attr_key(key)
  return normalize_key(key):gsub("%s+", "_"):gsub("%-", "_")
end

local relation_types = {
  positive_in = {
    label = "PositiveIn",
    aliases = {
      "PositiveIn",
      "ExpandsPositiveIn",
      "expands positively into",
      "positive in"
    },
    transitive = true,
    poset = true,
    attrs = {
      "semiring",
      "combinatorial_rule",
      "proof"
    }
  },
  contains = {
    label = "Contains",
    aliases = {
      "Contains",
      "SupersetOf",
      "is superset of",
      "superset of"
    },
    transitive = true,
    poset = true,
    attrs = {
      "scope",
      "proof"
    }
  },
  generalizes = {
    label = "Generalizes",
    aliases = {
      "Generalizes"
    },
    transitive = true,
    poset = true,
    attrs = {
      "scope",
      "proof"
    }
  },
  specializes_to = {
    label = "SpecializesTo",
    aliases = {
      "SpecializesTo",
      "specializes to"
    },
    transitive = true,
    poset = true,
    attrs = {
      "map",
      "parameter",
      "scope",
      "proof"
    }
  },
  degenerates_to = {
    label = "DegeneratesTo",
    aliases = {
      "DegeneratesTo",
      "degenerates to"
    },
    transitive = true,
    poset = true,
    attrs = {
      "map",
      "parameter",
      "scope",
      "proof"
    }
  },
  k_theoretic_analogue_of = {
    label = "KTheoreticAnalogueOf",
    aliases = {
      "KTheoreticAnalogueOf",
      "KAnalogueOf",
      "K-theoretic analogue of",
      "K theoretic analogue of"
    },
    transitive = false,
    poset = false,
    attrs = {
      "parameter",
      "scope",
      "proof"
    }
  },
  stable_limit = {
    label = "StableLimit",
    aliases = {
      "StableLimit",
      "stable limit"
    },
    transitive = true,
    poset = false,
    attrs = {
      "map",
      "scope",
      "proof"
    }
  },
  signed_in = {
    label = "SignedIn",
    aliases = {
      "SignedIn",
      "ExpandsSignedIn",
      "expands signed in"
    },
    transitive = false,
    poset = false,
    attrs = {
      "semiring",
      "sign_rule",
      "proof"
    }
  },
  transforms_to = {
    label = "TransformsTo",
    aliases = {
      "TransformsTo",
      "transforms to"
    },
    transitive = false,
    poset = false,
    attrs = {
      "map",
      "scope",
      "proof"
    }
  },
  dual_to = {
    label = "DualTo",
    aliases = {
      "DualTo",
      "dual to"
    },
    transitive = false,
    poset = false,
    attrs = {
      "pairing",
      "scope",
      "proof"
    }
  },
  nsym_qsym_dual = {
    label = "NSymQSymDual",
    aliases = {
      "NSymQSymDual"
    },
    transitive = false,
    poset = false,
    attrs = {
      "pairing",
      "scope",
      "proof"
    }
  },
  refines = {
    label = "Refines",
    aliases = {
      "Refines",
      "refines"
    },
    transitive = true,
    poset = false,
    attrs = {
      "map",
      "scope",
      "proof"
    }
  }
}

local common_attrs = {
  status = true,
  scope = true,
  note = true,
  include = true
}

local valid_statuses = {
  theorem = true,
  conjecture = true,
  question = true
}

local by_alias = {}
for type_name, spec in pairs(relation_types) do
  spec.type = type_name
  for _, alias in ipairs(spec.aliases or {}) do
    by_alias[normalize_key(alias)] = spec
  end
end

local function attr_set_for(spec)
  local attrs = {}
  for key in pairs(common_attrs) do
    attrs[key] = true
  end
  for _, key in ipairs((spec and spec.attrs) or {}) do
    attrs[normalize_attr_key(key)] = true
  end
  return attrs
end

function M.normalize_key(key)
  return normalize_key(key)
end

function M.normalize_attr_key(key)
  return normalize_attr_key(key)
end

function M.normalize_status(status)
  local normalized = normalize_key(status)
  if normalized == "" then
    return "theorem"
  end
  return normalized
end

function M.lookup_by_key(key)
  return by_alias[normalize_key(key)]
end

function M.get_type(type_name)
  return relation_types[type_name]
end

function M.is_valid_type(type_name)
  return relation_types[type_name] ~= nil
end

function M.is_valid_status(status)
  return valid_statuses[M.normalize_status(status)] == true
end

function M.is_allowed_attr(type_name, attr_key)
  local spec = relation_types[type_name]
  if not spec then
    return false
  end
  return attr_set_for(spec)[normalize_attr_key(attr_key)] == true
end

function M.types()
  return relation_types
end

return M

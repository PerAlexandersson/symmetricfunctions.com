-- Registry for structured relation rows inside polydata blocks.

local utils = dofile("utils.lua")
local trim = utils.trim

local M = {}

local function normalize_key(key)
  return (trim(key):lower():gsub("%s+", " "))
end

local function normalize_attr_key(key)
  return (normalize_key(key):gsub("%s+", "_"):gsub("%-", "_"))
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
  refined_by = {
    label = "RefinedBy",
    aliases = {
      "RefinedBy",
      "refined by"
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

-- ===== Shared helpers for relation records =================================

local function attr_is_false(value)
  if value == false then return true end
  if value == nil then return false end
  local text = trim(tostring(value)):lower()
  return text == "false" or text == "no" or text == "0"
end

--- Relations marked status=question or include=false stay in the data but
--- are not displayed.
function M.is_visible(relation)
  if type(relation) ~= "table" then return false end
  if relation.status == "question" then return false end
  if type(relation.attrs) == "table" and attr_is_false(relation.attrs.include) then
    return false
  end
  return true
end

--- Splits a comma-separated bibliography key list, dropping blanks.
function M.split_refs(text)
  local refs = {}
  for ref in (tostring(text or "") .. ","):gmatch("(.-),") do
    ref = trim(ref)
    if ref ~= "" then refs[#refs + 1] = ref end
  end
  return refs
end

--- Returns the de-duplicated bibliography keys of a relation, from its
--- `refs` list and its legacy comma-separated `ref` string.
function M.refs(relation)
  local refs, seen = {}, {}
  local function add(ref)
    ref = trim(ref)
    if ref ~= "" and not seen[ref] then
      refs[#refs + 1] = ref
      seen[ref] = true
    end
  end
  if type(relation.refs) == "table" then
    for _, ref in ipairs(relation.refs) do add(ref) end
  elseif relation.refs ~= nil then
    add(tostring(relation.refs))
  end
  for _, ref in ipairs(M.split_refs(relation.ref)) do add(ref) end
  return refs
end

--- Link to a family's anchor on its page.
function M.family_href(poly_id, entry)
  local page = (entry and entry.page) or ""
  if page ~= "" then
    return string.format("%s.htm#%s", page, poly_id)
  end
  return "#" .. poly_id
end

return M

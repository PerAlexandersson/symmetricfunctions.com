-- gather.lua — traverse AST once; log + lower TeX to Pandoc nodes in-place

local utils = dofile("utils.lua")
local trim = utils.trim
local capitalize_first = utils.capitalize_first
local set_add = utils.set_add
local set_to_sorted_list = utils.set_to_sorted_list
local print_todo = utils.print_todo
local print_warn = utils.print_warn
local print_color = utils.print_color
local print_info = utils.print_info
local print_error = utils.print_error
local CONSOLE = utils.CONSOLE


local bib = dofile("bibhandler.lua")
local get_bib_entry_label = bib.get_bib_entry_label


-- derive current input filename/stem
local _INPUT = (PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]) or "(stdin)"
local _BASENAME = _INPUT:match("([^/\\]+)$") or _INPUT
local _STEM = _BASENAME:gsub("%.[^.]+$", "")

-- ===== Lower block TeX macros/envs =========================================
-- Observe that proof -> symproof as pandoc eats that command
local theorem_envs = {
  "definition","proposition",
  "theorem","problem",
  "example","lemma",
  "conjecture","remark",
  "symproof",
  "question","solution"
}


-- ===== State to fill into meta ============================================
local metatitle   = nil  -- \metatitle{...}
local metadesc    = nil  -- \metadescription{...}
local citations   = {}   -- set
local labels      = {}   -- set
local urls_seen   = {}   -- set (url -> true), for logging
local todos       = {}   -- list (strings)
local families    = {}   -- list of {id=..., title=...}
local polydata    = {}   -- map name -> { key = value, ... }


-- ---- Unified link logging, in order to look for broken links perhaps -----------------------------------------

local function record_link(url, text)
  url  = url or ""
  text = text or ""
  local key = url .. "||" .. text
  if not urls_seen[key] then
    urls_seen[key] = true
    --print_color(CONSOLE.blue,"--- url=%s text=%s", url, text)
  end
end


-- To lazily define the custom handling.
local function make_filter()
  return {
    RawInline = RawInline,
    RawBlock  = RawBlock,
    Header    = Header,
    Link      = Link,
    Cite      = Cite,
    Quoted    = Quoted
  }
end

-- Parse a LaTeX fragment to blocks, then re-run our own filter on it
local function parse_blocks_walk(tex)

  local blocks = pandoc.read(tex, "latex+raw_tex").blocks
  -- Wrap/unwrap div
  local walked = pandoc.walk_block(pandoc.Div(blocks), make_filter())
  return walked.content
end

-- Parse a LaTeX inline fragment to inlines, then re-run our own filter
local function parse_inlines_walk(tex)
  local doc = pandoc.read(tex, "latex+raw_tex")
  local first = doc.blocks[1]
  local inlines = (first and first.t == "Para") and first.c or {}
  local walked  = pandoc.walk_inline(pandoc.Span(inlines), make_filter())
  return walked.content  -- unwrap the Span
end


-- Parse opt_text as LaTeX inlines and build a bold heading that can contain cites.
local function make_env_div(baseIn, opt_text, body_tex, starred)
  local base = (baseIn == "symproof") and "proof" or baseIn

  -- body blocks
  local body_blocks = parse_blocks_walk(body_tex or "")

  -- heading inlines: <strong>Base (Opt)</strong>.
  local strong_inls = pandoc.List()
  strong_inls:insert(pandoc.Str(capitalize_first(base)))
  if opt_text and opt_text ~= "" then
    strong_inls:insert(pandoc.Space())
    strong_inls:insert(pandoc.Str("("))
    local opt_inls = parse_inlines_walk(opt_text)
    for _, x in ipairs(opt_inls) do strong_inls:insert(x) end
    strong_inls:insert(pandoc.Str(")"))
  end

  local head_inls = pandoc.List()
  head_inls:insert(pandoc.Strong(strong_inls))
  head_inls:insert(pandoc.Str("."))

  -- The renderer turn this into <summary>
  local head_para = pandoc.Para(head_inls)

  -- assemble
  local blocks = pandoc.List({ head_para })
  blocks:extend(body_blocks)

  -- classes: env, base, (optional) collapsible
  local classes = {"env", base}
  if starred then classes[#classes+1] = "collapsible" end

  return pandoc.Div(blocks, pandoc.Attr("", classes))
end


-- Parse polydata body "Key & Value \\" lines → table
local function parse_polydata_body(body)
  local map = {}
  for line in (body.."\n"):gmatch("([^\n\r]+)\n") do
    local clean = line:gsub("%%.*$",""):gsub("\\\\%s*$","")
    local k, v = clean:match("^%s*([^&]-)%s*&%s*(.-)%s*$")
    if k and v and k~="" and v~="" then map[trim(k)] = trim(v) end
  end
  return map
end


-- ===== Pandoc node handlers ===============================================
function Header(el)

  -- Increase level
  el.level = math.min((el.level or 1) + 1, 6)

  if el.identifier and el.identifier ~= "" then
    set_add(labels, el.identifier)
    if el.level == 2 then
      --print_info("Section: %s", el.identifier)
    elseif el.level == 3 then
      --print_info("Subsection: %s", el.identifier)
    end
  end

  return el
end


function Cite(el)
  for _, c in ipairs(el.citations or {}) do
    if c.id and c.id~="" then
      set_add(citations, c.id)
      --print_color(CONSOLE.bright_cyan, "--- cite %s", c.id)
    end
  end
  return nil
end


function Quoted(el)
  local walked_span = pandoc.walk_inline(pandoc.Span(el.content or {}), make_filter())
  el.content = walked_span.content or {}
  return el
end

-----------------
-- pandoc recognizes href and hyperref, and converts to link directly
-----------------
function Link(el)
  local text = pandoc.utils.stringify(el.content)
  local url  = (type(el.target) == "string" and el.target)
               or (type(el.target) == "table" and (el.target[1] or el.target.url))
               or el.target or ""

  el.classes = el.classes or {}

  if url:match("^https?://oeis%.org/") then
    table.insert(el.classes, "oeis")
  elseif url:match("^#") then
    table.insert(el.classes, "hyperref")   -- internal anchors
  else
    table.insert(el.classes, "href")       -- generic external link
  end

  record_link(url, text)

  local classes = (#el.classes > 0) and table.concat(el.classes, " ") or "-"
--   print_info("Link url=%s  text=%s  classes=[%s]", url, text, classes)

  return el
end


function RawInline(el)
  if not el.format:match("tex") then return nil end

  local s = el.text
  
      -- \bigskip / \medskip / \smallskip used inline
    if s:match("^%s*\\bigskip%s*$") then
      return pandoc.Span(
        { pandoc.RawInline("html", "&#8203;") },
        pandoc.Attr("", {"vskip", "big"})
      )
    elseif s:match("^%s*\\medskip%s*$") then
      return pandoc.Span(
        { pandoc.RawInline("html", "&#8203;") },
        pandoc.Attr("", {"vskip", "med"})
      )
    elseif s:match("^%s*\\smallskip%s*$") then
      return pandoc.Span(
        { pandoc.RawInline("html", "&#8203;") },
        pandoc.Attr("", {"vskip", "small"})
      )
    end
 
  

  -- \defin{...} → Span(class=defin)
  do
    local b = s:match("^%s*\\defin(%b{})%s*$")
    if b then
      local inner = b:sub(2,-2)
      return pandoc.Span(parse_inlines_walk(inner), pandoc.Attr("", {"defin"}))
    end
  end

  -- \icon{...} → Span(class=icon)
  do
    local b = s:match("^%s*\\icon(%b{})%s*$")
    if b then
      local inner = b:sub(2,-2)
      return pandoc.Span(
        {},  -- no visible content
        pandoc.Attr(
          "",                       -- no id
          {"icon"},                 -- classes
          {["data-icon"] = inner}   -- attributes
        )
      )
    end
  end

  -- \ytableaushort appears as inline sometimes
  do
    local b = s:match("^%s*\\ytableaushort(%b{})%s*$")
    if b then
      return pandoc.RawInline("latextable", b)
    end
  end

  -- \svgimg
  do
    -- \svgimg[0.8]{path}{alt}
    local opt, path, alt = s:match("^%s*\\svgimg%s*(%b[])%s*(%b{})%s*(%b{})%s*$")
    if not path then
      -- \svgimg{path}{alt}
      path, alt = s:match("^%s*\\svgimg%s*(%b{})%s*(%b{})%s*$")
      opt=""
    end
    --If we found a file path
    if path then
      print_info("Image found (with opt): %s | %s | %s", opt, path, alt)

      local styleVal = ""
      local widthString="auto"
      if opt and opt ~= "" then
          --TODO parse more options 
          local num = opt:match("^([%d%.]+)%s*\\%a+width$")
          if num then
            local f = tonumber(num)
            if f and f > 0 then
              local p = math.floor(f * 100 + 0.5) 
              widthString=tostring(p) .. "%"
            end
          end
          styleVal = "width:" .. widthString ..";"
      end

      local attr = pandoc.Attr(
        "",          -- id
        {},          -- classes
        {{"style", styleVal}}
      )
      return pandoc.Image(pandoc.Str(alt), path, "", attr)
    end
  end

  -- \todo appears inline sometimes
  do
    local t = s:match("^%s*\\todo(%b{})%s*$")
    if t then
      local body = trim(t:sub(2,-2))
      todos[#todos+1] = body
      print_todo("%s", (body:gsub("\n"," "):sub(1,120)))
      return {}
    end
  end


  -- \oeis{Axxxxxx} → Link(id, https://oeis.org/id), class="oeis"
  -- <a title="The On-Line Encyclopedia of Integer Sequences" class="oeis" href="https://oeis.org/A000085">A000085</a>
    do
      local b = s:match("^%s*\\oeis(%b{})%s*$")
      if b then
        local id  = b:sub(2,-2)
        local url = "https://oeis.org/" .. id
        record_link(url, id)
        return pandoc.Link({pandoc.Str(id)},url, "The On-Line Encyclopedia of Integer Sequences", {"oeis"})
      end
    end

  -- \label{...} → a label span
  do
    local b = s:match("^%s*\\label(%b{})%s*$")
    if b then
      local id = b:sub(2,-2)
      set_add(labels, id)
      print_info("label: %s", id)
      -- Empty span with id; content left empty on purpose.
      return pandoc.Span({}, pandoc.Attr(id, {"label"}))
    end
  end

  -- \enquote{...} → Quoted(DoubleQuote, …)
  do
    local b = s:match("^%s*\\enquote(%b{})%s*$")
    if b then
      --print_color(CONSOLE.bright_cyan, "--- QUOTE %s", b)
      return pandoc.Quoted("DoubleQuote", parse_inlines_walk(b:sub(2,-2)))
    end
  end

  -- \cite[extra]{K} and \cite{K1,K2,...}
  do
    local opt, braced = s:match("^%s*\\cite%s*(%b[])%s*(%b{})%s*$")
    if not braced then
      braced = s:match("^%s*\\cite%s*(%b{})%s*$")
    end
    if braced then
      local extra = opt and opt:sub(2, -2) or ""
      local body  = braced:sub(2, -2)

      local parts, any_missing = {}, false
      for key in body:gmatch("[^,%s]+") do
        local lbl = get_bib_entry_label(key)
        if not lbl then
          print_error("Missing citation key: %s", key)
          parts[#parts+1] = pandoc.Str("UNDEF:" .. key)
          any_missing = true
        else
          set_add(citations, key)
          parts[#parts+1] = pandoc.Link({ pandoc.Str(lbl) }, "#" .. key, "", {"cite"})
        end
      end

      local inlines = { pandoc.Str("[") }
      if extra ~= "" then
        inlines[#inlines+1] = pandoc.Str(extra)
        inlines[#inlines+1] = pandoc.Str(", ")
      end
      for i, node in ipairs(parts) do
        if i > 1 then inlines[#inlines+1] = pandoc.Str(", ") end
        inlines[#inlines+1] = node
      end
      inlines[#inlines+1] = pandoc.Str("]")

      local classes = any_missing and {"citeSpan","missing"} or {"citeSpan"}
      return pandoc.Span(inlines, pandoc.Attr("", classes))
    end
  end

  return nil
end



-- Block TeX: meta, family, theorem-like envs, polydata, todo
function RawBlock(el)
  if not el.format:match("tex") then return nil end
  local s = el.text or ""

  -- \bigskip / \medskip / \smallskip
  if s:match("^%s*\\bigskip%s*$") then
    return pandoc.Div({ pandoc.RawInline("html","&#8203;") }, pandoc.Attr("", {"vskip","big"}))
  elseif s:match("^%s*\\medskip%s*$") then
    return pandoc.Div({ pandoc.RawInline("html","&#8203;") }, pandoc.Attr("", {"vskip","med"}))
  elseif s:match("^%s*\\smallskip%s*$") then
    return pandoc.Div({ pandoc.RawInline("html","&#8203;") }, pandoc.Attr("", {"vskip","small"}))
  end

  -- \metatitle{...}
  do
    local mt = s:match("^%s*\\metatitle(%b{})%s*$")
    if mt then metatitle = mt:sub(2,-2);
      print_color(CONSOLE.green, "::: metatitle: %s", metatitle)
      return {}
    end
  end

  -- \metadescription{...}
  do
    local md = s:match("^%s*\\metadescription(%b{})%s*$")
    if md then metadesc = md:sub(2,-2);
      print_color(CONSOLE.green, "::: metadescription: %s", metadesc)
      return {}
    end
  end

  -- \todo{...} — log & drop
  do
    local t = s:match("^%s*\\todo(%b{})%s*$")
    if t then
      local body = trim(t:sub(2,-2))
      todos[#todos+1] = body
      print_todo("%s", (body:gsub("\n"," "):sub(1,120)))
      return {}
    end
  end

  -- blockquote
  do
    local body = s:match("^%s*\\begin%s*%{blockquote%}%s*([%s%S]-)%s*\\end%s*%{blockquote%}%s*$")
    if body then
      return pandoc.BlockQuote(parse_blocks_walk(body))
    end
  end

  -- \family[ID]{Title} → Header(2, class=polynomialFamily, id=ID)
  do
    local O, T = s:match("^%s*\\family(%b[])(%b{})%s*$")
    if O and T then
      local id    = trim((O:sub(2,-2)) or "")
      local title = T:sub(2,-2)

      -- Log as a label, and as family
      set_add(labels, id)
      families[#families+1] = { id = id, title = title }

      print_info("family: id=%s title=%s", id, title)
      return pandoc.Header(2, parse_inlines_walk(title), pandoc.Attr(id, {"family"}))
    end
  end

  -- theorem-like envs: with [opt] or without
  for _, env in ipairs(theorem_envs) do
    -- with [opt]
    local O, B = s:match("^%s*\\begin%s*%{"..env.."%}%s*(%b[])%s*([%s%S]-)%s*\\end%s*%{"..env.."%}%s*$")
    if O and B then
      return make_env_div(env, O:sub(2,-2), B, false)
    end

    -- * with [opt]
    O, B = s:match("^%s*\\begin%s*%{"..env.."%*%}%s*(%b[])%s*([%s%S]-)%s*\\end%s*%{"..env.."%*%}%s*$")
    if O and B then
      return make_env_div(env, O:sub(2,-2), B, true)
    end

    -- without [opt]
    local B2 = s:match("^%s*\\begin%s*%{"..env.."%}%s*([%s%S]-)%s*\\end%s*%{"..env.."%}%s*$")
    if B2 then
      return make_env_div(env, "", B2, false)
    end

    -- * without [opt]
    B2 = s:match("^%s*\\begin%s*%{"..env.."%*%}%s*([%s%S]-)%s*\\end%s*%{"..env.."%*%}%s*$")
    if B2 then
      return make_env_div(env, "", B2, true)
    end

  end


  -- \begin{polydata}{name} ... \end{polydata} → meta.polydata[name] = {k=v,...}; drop block
  do
    local N, B = s:match("^%s*\\begin%s*%{polydata%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{polydata%}%s*$")
    if N and B then
      local name = trim(N:sub(2,-2))
      local map = parse_polydata_body(B)
      polydata[name] = map
      --print_info("polydata: %s (%d keys)", name, (function(n) local c=0 for _ in pairs(n) do c=c+1 end return c end)(map))
      return {}
    end
  end


  do
    local content = s:match("^%s*\\begin%s*%{symfig%}%s*([%s%S]-)%s*\\end%s*%{symfig%}%s*$")
    if content then
      --TODO use proper Figure tag with later Lua version
      return pandoc.Div(parse_blocks_walk(content),pandoc.Attr("", {"figure"}))
    end
  end

  ------- These are parsed to HTML later

  local TEXTABLES = {
   {name = "ytableau", pat = "^%s*(\\begin%s*%{ytableau%}%s*[%s%S]-%s*\\end%s*%{ytableau%})%s*$"},
   {name = "array", pat = "^%s*(\\begin%s*%{array%}%s*%b{}%s*[%s%S]-%s*\\end%s*%{array%})%s*$"},
   {name = "rawtabular", pat = "^%s*(\\begin%s*%{rawtabular%}%s*%b{}%s*[%s%S]-%s*\\end%s*%{rawtabular%})%s*$"},
   {name = "ytableaushort", pat = "^%s*(\\ytableaushort%b{})%s*$"}
  }

  do
    for _, m in ipairs(TEXTABLES) do
      local b = s:match(m.pat)
      if b then
        -- print_color(CONSOLE.bright_cyan, "--- %s", m.name)
        return pandoc.RawBlock("latextable", b)
      end
    end
  end

  print_warn("Tex string %s is unparsed", s)

  return nil
end

-- ===== Finalizer ===========================================================

-- after you’ve built `families` (a list of {id=..., title=...}) and `polydata` (map)
local function _first_n_names_from_families(n)
  local names = {}
  for _, f in ipairs(families or {}) do
    local pd = polydata and polydata[f.id]
    local name = (pd and pd.Name) or f.title or f.id
    names[#names+1] = name
    if #names == n then break end
  end
  return names
end

local function _clamp_descr(s)
  s = (s or ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
  if #s <= 155 then return s end
  s = s:sub(1, 155):gsub("%s+%S*$","") .. "…"
  return s
end


-- Make meta info automatically if not specified.
local function synthesize_meta(meta)
  local title = nil
  if #(families or {}) > 0 then
    local names = _first_n_names_from_families(3)
    if #names == 1 then
      title = names[1]
    elseif #names == 2 then
      title = names[1] .. " & " .. names[2]
    else
      title = table.concat({names[1], names[2]}, ", ") .. " & more"
    end
  end

  local descr = nil
  if #(families or {}) > 0 then
    local count = #families
    local parts = {}
    parts[#parts+1] = string.format(
      "Overview of %d symmetric-function famil%s",
      count, count == 1 and "y" or "ies"
    )
    local sample = _first_n_names_from_families(3)
    if #sample > 0 then
      parts[#parts+1] = " including " .. table.concat(sample, ", ")
    end
    descr = _clamp_descr(table.concat(parts, ". ") .. ".")
  end

  if title and (not meta.metatitle or meta.metatitle.t ~= "MetaString") then
    meta.metatitle = pandoc.MetaString(title)
  end
  if descr and (not meta.metadescription or meta.metadescription.t ~= "MetaString") then
    meta.metadescription = pandoc.MetaString(descr)
  end
end



-- ===== Finalizer ===========================================================
function Pandoc(doc)

  --print_info("Finalizing meta")
  local m = doc.meta


  if not metatitle then
    print_warn("Meta title missing")
  else
    m.metatitle = metatitle
  end

  if not metadesc then
    print_warn("Meta description missing")
  else
    m.metadescription = metadesc
  end

  -- Try to invent a description
  synthesize_meta(m)


  m.citations  = set_to_sorted_list(citations)
  m.labels     = set_to_sorted_list(labels)
  m.todos      = todos
  m.families   = families
  m.polydata   = polydata
  m.sourcestem = pandoc.MetaString(_STEM)

  local urls = {}
  for u,_ in pairs(urls_seen) do urls[#urls+1]=u end
  table.sort(urls)
  m.urls = urls

  return pandoc.Pandoc(doc.blocks, m)
end


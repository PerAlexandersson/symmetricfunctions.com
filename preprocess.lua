-- preprocess.lua — light, surgical text tweaks before Pandoc
-- usage: lua preprocess.lua [source.tex] [--no-figure] < in.tex > out.pre.tex

local utils = dofile("utils.lua")
local normalize_url = utils.normalize_url
local trim = utils.trim

-- ----- argument handling ----------------------------------------------------

local args = {}
local source_filename = nil

for _, a in ipairs(arg or {}) do
  if a:sub(1, 2) == "--" then
    args[a] = true
  elseif not source_filename then
    -- first non-option argument = filename (used only in \todo{...})
    source_filename = a
  else
    args[a] = true
  end
end

source_filename = source_filename or "<stdin>"

local function note(msg)
  -- io.stderr:write("↳ ", msg, "\n")
end

-- ----- read all stdin as one big string ------------------------------------

local input = io.read("*a")

-- ----- STEP 1: annotate \todo{...} with filename:lineno --------------------
-- Works even for multi-line bodies, because we only touch right after the `{`.

local function annotate_todos(text, fname)
  local out = {}
  local i = 1
  local line = 1
  local n = #text

  while i <= n do
    local j = text:find("\\todo%s*{", i)
    if not j then
      -- no more \todo, append rest
      local tail = text:sub(i)
      table.insert(out, tail)
      break
    end

    -- chunk before this \todo
    local chunk = text:sub(i, j - 1)
    table.insert(out, chunk)
    -- update line count based on chunk
    for _ in chunk:gmatch("\n") do
      line = line + 1
    end

    -- find the actual '{' after \todo and optional whitespace
    local brace_pos = text:find("{", j)
    if not brace_pos then
      -- malformed, just append rest and abort
      table.insert(out, text:sub(j))
      break
    end

    -- Copy "\todo...{" part as-is
    local prefix = text:sub(j, brace_pos)

    -- Inject filename:lineno right after the {
    local annotated = string.format("%s%s:%d ", prefix, fname, line)
    table.insert(out, annotated)

    -- continue scanning *after* the '{' (we don't consume the body)
    i = brace_pos + 1
  end

  return table.concat(out)
end

input = annotate_todos(input, source_filename)

-- ----- STEP 2: line-based normalization (bigskip/ytableaushort) ------------

-- Add newlines around \ytableaushort
-- Here is a good place to add newlines around other block-level macros if needed.
input = input:gsub("\\ytableaushort%b{}", "\n%0\n")


-- Split into lines for tweaks that may add blank lines.
local raw_lines = {}
for line in (input .. "\n"):gmatch("([^\n]*)\n") do
  table.insert(raw_lines, line)
end

local function is_comment_line(line)
  return trim(line):match("^%%")
end

local function is_pure_skip(line)
  return line:match("^%s*\\(bigskip|medskip|smallskip)%s*$")
end

local function contains_skip_inline(line)
  if is_pure_skip(line) then return false end
  return line:match("\\(bigskip|medskip|smallskip)")
end

local function is_pure_ytableaushort(line)
  return line:match("^%s*\\ytableaushort%b{}%s*$")
end

local function contains_ytableaushort_inline(line)
  if is_pure_ytableaushort(line) then return false end
  return line:match("\\ytableaushort%b{}")
end

local function normalize_blocks(lines)
  local out = {}

  local function push_blank_if_needed()
    if #out == 0 then return end
    if trim(out[#out]) ~= "" then
      table.insert(out, "")
    end
  end

  for i, line in ipairs(lines) do
    if is_comment_line(line) then
      table.insert(out, line)

    elseif is_pure_skip(line) then
      -- normalize skips to block: blank line before + after
      push_blank_if_needed()
      table.insert(out, trim(line))
      table.insert(out, "")

    elseif is_pure_ytableaushort(line) then
      -- normalize ytableaushort to block
      push_blank_if_needed()
      table.insert(out, trim(line))
      table.insert(out, "")

    else
      if contains_skip_inline(line) then
        io.stderr:write(
          string.format(
            "WARNING: inline \\bigskip/\\medskip/\\smallskip on line %d; " ..
            "these are intended as block-level macros.\n",
            i
          )
        )
      end
      if contains_ytableaushort_inline(line) then
        io.stderr:write(
          string.format(
            "WARNING: inline \\ytableaushort on line %d; " ..
            "it is intended to be on its own line.\n",
            i
          )
        )
      end
      table.insert(out, line)
    end
  end

  return out
end

local norm_lines = normalize_blocks(raw_lines)
input = table.concat(norm_lines, "\n")

-- ----- STEP 3: global substitutions -------------------------

--  Freeze figures: \begin{figure}...\end{figure} → symfig
input = input
    :gsub("\\begin%s*%{%s*figure%s*%}", "\\begin{symfig}")
    :gsub("\\end%s*%{%s*figure%s*%}",   "\\end{symfig}")
--  Replace only the begin/end tags; leave inner content untouched.
input = input
  :gsub("%{%s*proof%s*%}", "{symproof}")
  :gsub("%{%s*proof%*%s*%}",   "{symproof*}")

-- Pandoc eats tabular
input = input
  :gsub("\\begin%s*{tabular}(%b{})",
        "\\begin{rawtabular}%1")
  :gsub("\\end%s*{tabular}",
        "\\end{rawtabular}")


--  maps \url{theURL} -> \href{theURL-with-https-added}{theURL-with-http-stripped}
if not args["--no-url-rewrite"] then
  local before = input
  input = input:gsub("\\url%s*(%b{})",
    function(braced)
      local raw = braced:sub(2, -2)
      local href, display = normalize_url(raw)  -- from utils.lua
      return "\\href{" .. href .. "}{" .. display .. "}"
    end)
end

--  \filelink{path}{label} -> \href{path}{label} (styled via CSS)
input = input:gsub("\\filelink", "\\href")

--  Fix \section[label]{Title} into \section{Title}\label{label}
input = input
  :gsub("\\section%[(.-)%]%s*(%b{})",      "\\section%2\\label{%1}")
  :gsub("\\subsection%[(.-)%]%s*(%b{})",   "\\subsection%2\\label{%1}")
  :gsub("\\subsubsection%[(.-)%]%s*(%b{})","\\subsubsection%2\\label{%1}")



-- ----- write result --------------------------------------------------------

io.write(input)


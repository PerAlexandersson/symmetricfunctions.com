-- ============================================================================
-- preprocess.lua — Light, surgical text tweaks before Pandoc
-- ============================================================================
-- Performs preprocessing on LaTeX files before passing to Pandoc:
-- 1. Annotates \todo{} commands with filename:lineno
-- 2. Normalizes block-level macros (bigskip, ytableaushort) with blank lines
-- 3. Rewrites various LaTeX commands for better Pandoc compatibility
--
-- Usage: lua preprocess.lua [source.tex] [--no-url-rewrite] < in.tex > out.pre.tex
-- ============================================================================

local utils = dofile("utils.lua")
local normalize_url = utils.normalize_url
local trim = utils.trim

-- ============================================================================
-- Argument Parsing
-- ============================================================================

--- Parse command-line arguments into flags and source filename
--- @return table args Flags from --arguments
--- @return string source_filename First non-flag argument (or "<stdin>")
local function parse_arguments()
  local flags = {}
  local filename = nil

  for _, a in ipairs(arg or {}) do
    if a:sub(1, 2) == "--" then
      flags[a] = true
    elseif not filename then
      -- First non-option argument = filename (used for \todo annotations)
      filename = a
    else
      flags[a] = true
    end
  end

  return flags, filename or "<stdin>"
end

local args, source_filename = parse_arguments()

-- ============================================================================
-- Input Reading
-- ============================================================================

local input = io.read("*a")

-- ============================================================================
-- STEP 1: Annotate \todo{...} with filename:lineno
-- ============================================================================

--- Annotate all \todo{} commands with the source filename and line number.
--- Injects "filename:lineno " right after the opening brace of \todo{}.
--- @param text string Input LaTeX text
--- @param fname string Source filename to use in annotations
--- @return string Text with annotated \todo commands
local function annotate_todos(text, fname)
  local out = {}
  local i = 1
  local line = 1
  local n = #text

  while i <= n do
    -- Look for \todo followed by optional whitespace and {
    local todo_start, todo_end = text:find("\\todo%s*{", i)
    if not todo_start then
      -- No more \todo, append rest
      table.insert(out, text:sub(i))
      break
    end

    -- Chunk before this \todo
    local chunk = text:sub(i, todo_start - 1)
    table.insert(out, chunk)
    
    -- Update line count based on newlines in chunk
    for _ in chunk:gmatch("\n") do
      line = line + 1
    end

    -- Copy "\todo...{" part as-is, then inject filename:lineno
    local prefix = text:sub(todo_start, todo_end)
    local annotated = string.format("%s%s:%d ", prefix, fname, line)
    table.insert(out, annotated)

    -- Continue scanning after the '{'
    i = todo_end + 1
  end

  return table.concat(out)
end

input = annotate_todos(input, source_filename)

-- ============================================================================
-- STEP 2: Line-based Normalization (Block-level Macros)
-- ============================================================================

-- Add newlines around \ytableaushort to make it block-level
-- TODO: EDGE CASE if ytableaushort is inside a commented line
input = input:gsub("\\ytableaushort%b{}", "\n%0\n")

-- Split into lines for further processing
local raw_lines = {}
for line in (input .. "\n"):gmatch("([^\n]*)\n") do
  table.insert(raw_lines, line)
end

--- Check if a line is a LaTeX comment line.
--- @param line string Line to check
--- @return boolean true if line starts with % (ignoring whitespace)
local function is_comment_line(line)
  return trim(line):match("^%%") ~= nil
end

--- Check if a line contains only a vertical skip command (bigskip/medskip/smallskip).
--- @param line string Line to check
--- @return boolean true if line is purely a skip command
local function is_standalone_skip(line)
  local trimmed = trim(line)
  return trimmed == "\\bigskip" or trimmed == "\\medskip" or trimmed == "\\smallskip"
end

--- Check if a line contains a skip command inline with other content.
--- @param line string Line to check
--- @return boolean true if line has a skip command but isn't standalone
local function has_inline_skip(line)
  if is_standalone_skip(line) then return false end
  return line:find("\\bigskip")~=nil or line:find("\\medskip")~=nil or line:find("\\smallskip")~=nil
end

--- Check if a line contains only \ytableaushort{...}.
--- @param line string Line to check
--- @return boolean true if line is purely \ytableaushort
local function is_standalone_ytableaushort(line)
  return line:match("^%s*\\ytableaushort%b{}%s*$") ~= nil
end

--- Check if a line contains \ytableaushort inline with other content.
--- @param line string Line to check
--- @return boolean true if line has \ytableaushort but isn't standalone
local function has_inline_ytableaushort(line)
  if is_standalone_ytableaushort(line) then return false end
  return line:find("\\ytableaushort") ~= nil
end

--- Normalize block-level macros by ensuring blank lines before and after.
--- Also warns about inline usage of block-level macros.
--- @param lines table Array of input lines
--- @return table Normalized array of lines
local function normalize_blocks(lines)
  local out = {}

  --- Add a blank line if the last line isn't already blank
  local function ensure_blank_line_before()
    if #out == 0 then return end
    if trim(out[#out]) ~= "" then
      table.insert(out, "")
    end
  end

  for i, line in ipairs(lines) do
    if is_comment_line(line) then
      table.insert(out, line)
    elseif is_standalone_skip(line) then
      -- Normalize skips to block: blank line before + after
      ensure_blank_line_before()
      table.insert(out, trim(line))
      table.insert(out, "")
    elseif is_standalone_ytableaushort(line) then
      -- Normalize ytableaushort to block
      ensure_blank_line_before()
      table.insert(out, trim(line))
      table.insert(out, "")
    else
      -- Warn about inline usage of block-level macros
      if has_inline_skip(line) then
        io.stderr:write(
          string.format(
            "WARNING: inline \\bigskip/\\medskip/\\smallskip on line %d; " ..
            "these are intended as block-level macros.\n",
            i
          )
        )
      end
      if has_inline_ytableaushort(line) then
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

-- ============================================================================
-- STEP 3: Global Substitutions and Rewrites
-- ============================================================================

--- Escape special Lua pattern characters in a string for literal matching.
--- @param s string String to escape
--- @return string Escaped string safe for Lua patterns
local function escape_pattern(s)
  return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end

-- Freeze figures: \begin{figure}...\end{figure} → symfig
-- This prevents Pandoc from moving/reordering figure environments
input = input
    :gsub("\\begin%s*{%s*figure%s*}", "\\begin{symfig}")
    :gsub("\\end%s*{%s*figure%s*}", "\\end{symfig}")

-- Rename proof environments to symproof (including starred variants)
input = input
    :gsub("{%s*proof%s*}", "{symproof}")
    :gsub("{%s*proof%*%s*}", "{symproof*}")

-- Rename tabular to rawtabular to prevent Pandoc from processing it
input = input
    :gsub("\\begin%s*{%s*tabular%s*}(%b{})", "\\begin{rawtabular}%1")
    :gsub("\\end%s*{%s*tabular%s*}", "\\end{rawtabular}")

-- Rewrite \url{URL} to \href{normalized-URL}{display-URL}
-- Adds https:// scheme if missing and creates clean display text
if not args["--no-url-rewrite"] then
  input = input:gsub("\\url%s*(%b{})",
    function(braced)
      local raw = braced:sub(2, -2)
      if raw == "" then return braced end  -- Skip empty URLs
      local href, display = normalize_url(raw)
      return string.format("\\href{%s}{%s}", href, display)
    end)
end

-- Rewrite \filelink{path}{label} to \href{path}{label}
-- CSS will style these differently from regular links
input = input:gsub("\\filelink", "\\href")

-- Fix section commands with labels: \section[label]{Title} → \section{Title}\label{label}
-- This provides better Pandoc compatibility
input = input
    :gsub("\\section%s*%[(.-)%]%s*(%b{})", "\\section%2\\label{%1}")
    :gsub("\\subsection%s*%[(.-)%]%s*(%b{})", "\\subsection%2\\label{%1}")
    :gsub("\\subsubsection%s*%[(.-)%]%s*(%b{})", "\\subsubsection%2\\label{%1}")

-- ============================================================================
-- Output
-- ============================================================================

io.write(input)
-- ============================================================================
-- preprocess.lua — Light, surgical text tweaks before Pandoc
-- ============================================================================
-- Performs preprocessing on LaTeX files before passing to Pandoc:
-- 1. Annotates \todo{} commands with filename:lineno
-- 2. Annotates \cite{} and \hyperref[] commands with filename:lineno
-- 3. Normalizes block-level macros (bigskip, ytableaushort) with blank lines
-- 4. Rewrites various LaTeX commands for better Pandoc compatibility
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

--- Annotate all \cite{} commands with source filename and line number.
--- Rewrites \cite{keys} → \cite{keys@@file:line} and
--- \cite[opt]{keys} → \cite[opt]{keys@@file:line}.
--- The @@file:line suffix is stripped in gather.lua and used for error messages.
--- @param text string Input LaTeX text
--- @param fname string Source filename to use in annotations
--- @return string Text with annotated \cite commands
local function annotate_cites(text, fname)
  local out = {}
  local i = 1
  local line = 1
  local n = #text

  while i <= n do
    local cite_start, cite_end = text:find("\\cite", i, true)
    if not cite_start then
      table.insert(out, text:sub(i))
      break
    end

    -- Chunk before this \cite
    local chunk = text:sub(i, cite_start - 1)
    table.insert(out, chunk)
    for _ in chunk:gmatch("\n") do line = line + 1 end

    -- Copy \cite
    table.insert(out, "\\cite")
    local j = cite_end + 1

    -- Skip optional whitespace
    while j <= n and text:sub(j, j):match("%s") do
      if text:sub(j, j) == "\n" then line = line + 1 end
      table.insert(out, text:sub(j, j))
      j = j + 1
    end

    -- Skip optional [...]
    if j <= n and text:sub(j, j) == "[" then
      local depth = 1
      table.insert(out, "[")
      j = j + 1
      while j <= n and depth > 0 do
        local ch = text:sub(j, j)
        if ch == "[" then depth = depth + 1
        elseif ch == "]" then depth = depth - 1
        elseif ch == "\n" then line = line + 1 end
        table.insert(out, ch)
        j = j + 1
      end
      -- Skip whitespace between [...] and {
      while j <= n and text:sub(j, j):match("%s") do
        if text:sub(j, j) == "\n" then line = line + 1 end
        table.insert(out, text:sub(j, j))
        j = j + 1
      end
    end

    -- Now expect {keys} — inject @@file:line before closing }
    if j <= n and text:sub(j, j) == "{" then
      local depth = 1
      local brace_start = j
      j = j + 1
      while j <= n and depth > 0 do
        local ch = text:sub(j, j)
        if ch == "{" then depth = depth + 1
        elseif ch == "}" then depth = depth - 1
        elseif ch == "\n" then line = line + 1 end
        j = j + 1
      end
      -- brace_start .. j-1 is the full {keys}
      local body = text:sub(brace_start + 1, j - 2) -- without braces
      local loc = string.format("@@%s:%d", fname, line)
      table.insert(out, "{" .. body .. loc .. "}")
    end

    i = j
  end

  return table.concat(out)
end

--- Annotate all \hyperref[label]{text} commands with source filename and line number.
--- Rewrites \hyperref[label]{text} → \hyperref[label@@file:line]{text}.
--- The @@file:line suffix is stripped in gather.lua and used for error messages.
--- @param text string Input LaTeX text
--- @param fname string Source filename to use in annotations
--- @return string Text with annotated \hyperref commands
local function annotate_hyperrefs(text, fname)
  local out = {}
  local i = 1
  local line = 1
  local n = #text

  while i <= n do
    local ref_start, ref_end = text:find("\\hyperref", i, true)
    if not ref_start then
      table.insert(out, text:sub(i))
      break
    end

    local chunk = text:sub(i, ref_start - 1)
    table.insert(out, chunk)
    for _ in chunk:gmatch("\n") do line = line + 1 end

    table.insert(out, "\\hyperref")
    local j = ref_end + 1

    while j <= n and text:sub(j, j):match("%s") do
      if text:sub(j, j) == "\n" then line = line + 1 end
      table.insert(out, text:sub(j, j))
      j = j + 1
    end

    if j <= n and text:sub(j, j) == "[" then
      local depth = 1
      local bracket_start = j
      j = j + 1
      while j <= n and depth > 0 do
        local ch = text:sub(j, j)
        if ch == "[" then depth = depth + 1
        elseif ch == "]" then depth = depth - 1
        elseif ch == "\n" then line = line + 1 end
        j = j + 1
      end
      local body = text:sub(bracket_start + 1, j - 2)
      local loc = string.format("@@%s:%d", fname, line)
      table.insert(out, "[" .. body .. loc .. "]")
    end

    while j <= n and text:sub(j, j):match("%s") do
      if text:sub(j, j) == "\n" then line = line + 1 end
      table.insert(out, text:sub(j, j))
      j = j + 1
    end

    if j <= n and text:sub(j, j) == "{" then
      local depth = 1
      local brace_start = j
      j = j + 1
      while j <= n and depth > 0 do
        local ch = text:sub(j, j)
        if ch == "{" then depth = depth + 1
        elseif ch == "}" then depth = depth - 1
        elseif ch == "\n" then line = line + 1 end
        j = j + 1
      end
      table.insert(out, text:sub(brace_start, j - 1))
    end

    i = j
  end

  return table.concat(out)
end

--- Annotate the first braced argument of a command, optionally after an optional [...] block.
--- Rewrites \command[opt]{arg}... → \command[opt]{arg@@file:line}...
--- @param text string Input LaTeX text
--- @param fname string Source filename to use in annotations
--- @param command string Command name without leading backslash
--- @param has_optional boolean Whether the command may have an initial optional [...] argument
--- @return string
local function annotate_first_braced_arg(text, fname, command, has_optional)
  local needle = "\\" .. command
  local out = {}
  local i = 1
  local line = 1
  local n = #text

  while i <= n do
    local cmd_start, cmd_end = text:find(needle, i, true)
    if not cmd_start then
      table.insert(out, text:sub(i))
      break
    end

    local chunk = text:sub(i, cmd_start - 1)
    table.insert(out, chunk)
    for _ in chunk:gmatch("\n") do line = line + 1 end

    table.insert(out, needle)
    local j = cmd_end + 1

    while j <= n and text:sub(j, j):match("%s") do
      if text:sub(j, j) == "\n" then line = line + 1 end
      table.insert(out, text:sub(j, j))
      j = j + 1
    end

    if has_optional and j <= n and text:sub(j, j) == "[" then
      local depth = 1
      local opt_start = j
      j = j + 1
      while j <= n and depth > 0 do
        local ch = text:sub(j, j)
        if ch == "[" then depth = depth + 1
        elseif ch == "]" then depth = depth - 1
        elseif ch == "\n" then line = line + 1 end
        j = j + 1
      end
      table.insert(out, text:sub(opt_start, j - 1))

      while j <= n and text:sub(j, j):match("%s") do
        if text:sub(j, j) == "\n" then line = line + 1 end
        table.insert(out, text:sub(j, j))
        j = j + 1
      end
    end

    if j <= n and text:sub(j, j) == "{" then
      local depth = 1
      local brace_start = j
      j = j + 1
      while j <= n and depth > 0 do
        local ch = text:sub(j, j)
        if ch == "{" then depth = depth + 1
        elseif ch == "}" then depth = depth - 1
        elseif ch == "\n" then line = line + 1 end
        j = j + 1
      end
      local body = text:sub(brace_start + 1, j - 2)
      local loc = string.format("@@%s:%d", fname, line)
      table.insert(out, "{" .. body .. loc .. "}")
    end

    i = j
  end

  return table.concat(out)
end

-- The full input text as one big string
input = annotate_todos(input, source_filename)
input = annotate_cites(input, source_filename)
input = annotate_hyperrefs(input, source_filename)
input = annotate_first_braced_arg(input, source_filename, "svgimg", true)
input = annotate_first_braced_arg(input, source_filename, "includegraphics", true)
input = annotate_first_braced_arg(input, source_filename, "icon", false)
input = annotate_first_braced_arg(input, source_filename, "topiccard", false)

-- ============================================================================
-- STEP 1B: Normalize raw angle brackets in math
-- ============================================================================

local math_envs = {
  ["align"] = true,
  ["align*"] = true,
  ["aligned"] = true,
  ["array"] = true,
  ["bmatrix"] = true,
  ["cases"] = true,
  ["equation"] = true,
  ["equation*"] = true,
  ["gather"] = true,
  ["gather*"] = true,
  ["matrix"] = true,
  ["multline"] = true,
  ["multline*"] = true,
  ["pmatrix"] = true,
  ["smallmatrix"] = true,
  ["vmatrix"] = true,
}

local verbatim_envs = {
  ["lstlisting"] = true,
  ["verbatim"] = true,
  ["verbatim*"] = true,
}

local function starts_with(text, pos, needle)
  return text:sub(pos, pos + #needle - 1) == needle
end

local function is_escaped(text, pos)
  local count = 0
  local i = pos - 1
  while i >= 1 and text:sub(i, i) == "\\" do
    count = count + 1
    i = i - 1
  end
  return count % 2 == 1
end

local function parse_begin_env(text, pos)
  local prefix = "\\begin{"
  if not starts_with(text, pos, prefix) then
    return nil, nil
  end

  local name_start = pos + #prefix
  local close = text:find("}", name_start, true)
  if not close then
    return nil, nil
  end

  return text:sub(name_start, close - 1), close
end

local function rewrite_angle_math_body(text, pos, close_len_at)
  local out = {}
  local i = pos
  local n = #text

  while i <= n do
    local close_len = close_len_at(text, i)
    if close_len then
      return table.concat(out), i, close_len
    end

    local ch = text:sub(i, i)
    if ch == "<" then
      table.insert(out, "\\lt{}")
    elseif ch == ">" then
      table.insert(out, "\\gt{}")
    else
      table.insert(out, ch)
    end
    i = i + 1
  end

  return table.concat(out), n + 1, 0
end

local function rewrite_angle_brackets_in_math(text)
  local out = {}
  local i = 1
  local n = #text

  while i <= n do
    if starts_with(text, i, "\\(") then
      table.insert(out, "\\(")
      local body, close_pos, close_len = rewrite_angle_math_body(text, i + 2, function(s, pos)
        return starts_with(s, pos, "\\)") and 2 or nil
      end)
      table.insert(out, body)
      if close_len > 0 then
        table.insert(out, text:sub(close_pos, close_pos + close_len - 1))
      end
      i = close_pos + close_len

    elseif starts_with(text, i, "\\[") then
      table.insert(out, "\\[")
      local body, close_pos, close_len = rewrite_angle_math_body(text, i + 2, function(s, pos)
        return starts_with(s, pos, "\\]") and 2 or nil
      end)
      table.insert(out, body)
      if close_len > 0 then
        table.insert(out, text:sub(close_pos, close_pos + close_len - 1))
      end
      i = close_pos + close_len

    elseif starts_with(text, i, "$$") and not is_escaped(text, i) then
      table.insert(out, "$$")
      local body, close_pos, close_len = rewrite_angle_math_body(text, i + 2, function(s, pos)
        return starts_with(s, pos, "$$") and not is_escaped(s, pos) and 2 or nil
      end)
      table.insert(out, body)
      if close_len > 0 then
        table.insert(out, "$$")
      end
      i = close_pos + close_len

    elseif text:sub(i, i) == "$" and not is_escaped(text, i) then
      table.insert(out, "$")
      local body, close_pos, close_len = rewrite_angle_math_body(text, i + 1, function(s, pos)
        return s:sub(pos, pos) == "$" and not is_escaped(s, pos) and 1 or nil
      end)
      table.insert(out, body)
      if close_len > 0 then
        table.insert(out, "$")
      end
      i = close_pos + close_len

    else
      local env, begin_close = parse_begin_env(text, i)
      if env and verbatim_envs[env] then
        local end_delim = "\\end{" .. env .. "}"
        local close_start = text:find(end_delim, begin_close + 1, true)
        if close_start then
          table.insert(out, text:sub(i, close_start + #end_delim - 1))
          i = close_start + #end_delim
        else
          table.insert(out, text:sub(i))
          i = n + 1
        end
      elseif env and math_envs[env] then
        table.insert(out, text:sub(i, begin_close))
        local end_delim = "\\end{" .. env .. "}"
        local body, close_pos, close_len = rewrite_angle_math_body(text, begin_close + 1, function(s, pos)
          return starts_with(s, pos, end_delim) and #end_delim or nil
        end)
        table.insert(out, body)
        if close_len > 0 then
          table.insert(out, end_delim)
        end
        i = close_pos + close_len
      else
        table.insert(out, text:sub(i, i))
        i = i + 1
      end
    end
  end

  return table.concat(out)
end

input = rewrite_angle_brackets_in_math(input)

-- ============================================================================
-- STEP 2: Line-based Normalization (Block-level Macros)
-- ============================================================================

-- Add newlines to make it block-level

input = input:gsub("([^\n]*)(\\specialblock%b{})", function(prefix, command)
    -- Check if the prefix contains % (then its commented out)
    if prefix:match("%%") then
        -- Return exactly what was found (do nothing).
        return prefix .. command
    else
        -- It is safe to force block formatting.
        return prefix .. "\n" .. command .. "\n"
    end
end)

input = input:gsub("([^\n]*)(\\ytableaushort%b{})", function(prefix, command)
    -- Check if the prefix contains any non-whitespace characters (%S matches non-whitespace)
    if prefix:match("%S") then
        return prefix .. command
    else
        return prefix .. "\n" .. command .. "\n"
    end
end)


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

-- Keep \filelink intact; gather.lua lowers it to a link with class="dataFile".

-- Fix section commands with labels: \section[label]{Title} → \section{Title}\label{label}
-- This provides better Pandoc compatibility
input = input
    :gsub("\\section%s*%[(.-)%]%s*(%b{})", "\\section%2\\label{%1}")
    :gsub("\\subsection%s*%[(.-)%]%s*(%b{})", "\\subsection%2\\label{%1}")
    :gsub("\\subsubsection%s*%[(.-)%]%s*(%b{})", "\\subsubsection%2\\label{%1}")


-- ============================================================================
-- STEP 4: Typographical Fixes (Math Punctuation)
-- ============================================================================

-- Rewrite $stuff$. to $stuff.$ (and , :)
-- assumption: $ is exclusively used for math delimiters.
input = input:gsub("(%b$$)([%.,:])", function(math_seq, punct)
  -- If it is display math ($$ ... $$), do nothing.
  if math_seq:sub(2,2) == "$" then
    return math_seq .. punct
  else
    -- It is inline math ($ ... $). Move punctuation inside.
    -- Chop off the last '$', add punct, add '$' back.
    return math_seq:sub(1, -2) .. punct .. "$"
  end
end)

-- Rewrite \(stuff\). to \(stuff.\) (and , :)
-- Matches: \( ... \) followed optionally by whitespace, then . , or :
input = input:gsub("\\%((.-)\\%)%s*([%.,:])", "\\(%1%2\\)")

-- ============================================================================
-- Output
-- ============================================================================

io.write(input)

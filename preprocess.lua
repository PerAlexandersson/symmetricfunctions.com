-- preprocess.lua — light, surgical text tweaks before Pandoc
-- usage: lua preprocess.lua [--no-figure] < in.tex > out.pre.tex

local utils = dofile("utils.lua")
local normalize_url = utils.normalize_url

local args = {}
for _,a in ipairs(arg) do args[a] = true end

-- simple console helpers
local function note(msg)
--  io.stderr:write("↳ ", msg, "\n")
end

-- read all stdin
local input = io.read("*a")

-- (A) Freeze figures: \begin{figure}...\end{figure} → symfig
if not args["--no-figure"] then
  local before = input
  -- Replace only the begin/end tags; leave inner content untouched.
  input = input
    :gsub("\\begin%s*%{%s*figure%s*%}", "\\begin{symfig}")
    :gsub("\\end%s*%{%s*figure%s*%}",   "\\end{symfig}")
  if input ~= before then note("figure environments frozen as symfig") end
end


-- maps \url{theURL} -> \href{theURL-with-https-added}{theURL-with-http-stripped}
if not args["--no-url-rewrite"] then
  local before = input
  input = input:gsub("\\url%s*(%b{})",
    function(braced)
      local raw = braced:sub(2, -2)
      local href, display = normalize_url(raw)  -- from utils.lua
      return "\\href{" .. href .. "}{" .. display .. "}"
    end)
  if input ~= before then note("replaced \\url with \\href") end
end

-- \filelink{path}{label} -> \href{path}{label} (styled via CSS)
input = input:gsub("\\filelink", "\\href")


-- Replace only the begin/end tags; leave inner content untouched.
input = input
        :gsub("%{%s*proof%s*%}", "{symproof}")
        :gsub("%{%s*proof%*%s*%}",   "{symproof*}")


-- Pandoc eats tabular
input = input
    :gsub("\\begin%s*{tabular}(%b{})",
          "\\begin{rawtabular}%1")
    :gsub("\\end%s*{tabular}",
          "\\end{rawtabular}")


-- Pandoc eats the label in \section[label]{The section title},
-- so we turn it into regular labels. 
-- Pandoc will then interpret this correctly.
input = input
  :gsub("\\section%[(.-)%]%s*(%b{})",      "\\section%2\\label{%1}")
  :gsub("\\subsection%[(.-)%]%s*(%b{})",   "\\subsection%2\\label{%1}")
  :gsub("\\subsubsection%[(.-)%]%s*(%b{})","\\subsubsection%2\\label{%1}")

io.write(input)

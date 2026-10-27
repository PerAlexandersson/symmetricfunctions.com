-- Regression checks for build safeguards: inputs that used to be dropped or
-- mangled silently must now fail with a clear message, and the table,
-- bibliography and duplicate-id fixes must hold.  Scratch files live under
-- TEST_META_DIR/safeguards.

local function fail(message)
  io.stderr:write("[ERROR] safeguards: " .. message .. "\n")
  os.exit(1)
end

local function contains(text, needle)
  return tostring(text or ""):find(needle, 1, true) ~= nil
end

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function run(command)
  local pipe = io.popen("NO_COLOR=1 " .. command .. " 2>&1")
  if not pipe then fail("could not run command: " .. command) end
  local output = pipe:read("*a")
  local ok = pipe:close()
  return ok == true, output
end

local scratch = (os.getenv("TEST_META_DIR") or "temp/test-www/meta") .. "/safeguards"
os.execute("rm -rf " .. shell_quote(scratch) .. " && mkdir -p " .. shell_quote(scratch))

local function write(name, text)
  local path = scratch .. "/" .. name
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
  return path
end

local reader = os.getenv("READER") or "latex+raw_tex-auto_identifiers"
local case_count = 0

--- Runs preprocess + gather on a page body; returns success and output.
local function gather(body, with_meta)
  case_count = case_count + 1
  local header = with_meta == false and ""
      or "\\metatitle{Safeguard case}\n\\metadescription{Safeguard case.}\n\n"
  local path = write("case" .. case_count .. ".tex", header .. body .. "\n")
  local json = path:gsub("%.tex$", ".json")
  local ok, output = run("lua preprocess.lua " .. shell_quote(path) .. " < " .. shell_quote(path) ..
      " | pandoc --from=" .. reader .. " --to=json --lua-filter=gather.lua" ..
      " --fail-if-warnings -o " .. shell_quote(json))
  return ok, output, json
end

local function expect_error(body, diagnostic, with_meta)
  local ok, output = gather(body, with_meta)
  if ok then fail("accepted input that should fail (" .. diagnostic .. "):\n" .. body) end
  if not contains(output, diagnostic) then
    fail("expected diagnostic '" .. diagnostic .. "', got:\n" .. output)
  end
end

local function expect_ok(body)
  local ok, output, json = gather(body)
  if not ok then fail("rejected valid input:\n" .. body .. "\n" .. output) end
  local f = assert(io.open(json))
  local text = f:read("*a")
  f:close()
  return text
end

local function polydata(rows)
  return "\\section[safeFamily]{Safe family}\n\\begin{polydata}{safeFamily}\n" ..
      "  Name & Safe \\\\\n  Space & Sym \\\\\n  Year & 2000 \\\\\n  Rating & 1 \\\\\n" ..
      rows .. "\n\\end{polydata}\n"
end

-- ===== Content that would be dropped is an error ===========================

expect_error("\\begin{claim}Kept?\\end{claim}", "Unsupported TeX block")
expect_error("Some \\unknownmacro{text} here.", "Unsupported inline TeX")
expect_error("\\section{No label}\nText.", "Section without a label")
expect_error("A \\defin{first\n\nsecond} term.", "single paragraph")
expect_error("\\svgimg[height=2cm]{svg-images/logo.svg}{Logo}", "unsupported \\svgimg option")
expect_error("Text.", "Missing \\metatitle", false)

-- ===== polydata rows ========================================================

expect_error(polydata("  Generalizs & safeFamily | Cauchy1815 \\\\"),
  "unknown field or relation 'Generalizs'")
expect_error(polydata("  Year & 2001 \\\\"), "field 'Year' given twice")
expect_error(polydata("  Name only \\\\"), "line without 'Key & value'")
expect_error(polydata("  Symbol & \\\\"), "empty value for 'Symbol'")
expect_error(polydata("  Contains & a | Cauchy1815; b | Jacobi1841 | status=conjecture \\\\"),
  "malformed relation row")
expect_error(polydata("  Contains & safeFamily | Cauchy1815 | \\\\"), "malformed relation row")
expect_error(polydata("  Contains & safeFamily | Cauchy1815 | note \\\\"), "malformed relation row")

local accepted = expect_ok(polydata(table.concat({
  "  Keywords & 100\\% safe % a comment \\\\",
  "  Contains & safeFamily | Cauchy1815; safeFamily [Jacobi1841] \\\\",
  "  SignedIn & safeFamily | Cauchy1815 | sign_rule=$(-1)^{|\\mu|}$; note=pipes \\\\",
}, "\n")))
if not contains(accepted, [[100\\% safe]]) or contains(accepted, "a comment") then
  fail("polydata value with \\% or a trailing comment was mangled")
end
if not contains(accepted, [[(-1)^{|\\mu|}]]) then
  fail("attribute value containing | was mangled")
end

-- ===== Preprocessing ========================================================

local pre_src = write("preprocess.tex", table.concat({
  "Rows a\\\\[2pt] b < c and $d < e$.",
  "\\bigskip % a note",
  "Size \\iconsize{3} and \\icon{star}.",
  "\\begin{tabular}[t]{ll} a & b \\end{tabular}",
  "Text with \\medskip inline.",
}, "\n") .. "\n")
local pre_ok, pre_out = run("lua preprocess.lua " .. shell_quote(pre_src) .. " < " .. shell_quote(pre_src))
if not pre_ok then fail("preprocess failed:\n" .. pre_out) end
if not contains(pre_out, "b < c and $d \\lt{} e.$") then
  fail("\\\\[2pt] was treated as display math")
end
if not contains(pre_out, "\n\n\\bigskip % a note\n\n") then
  fail("\\bigskip followed by a comment was not normalized to a block")
end
if contains(pre_out, "\\iconsize{3@@") or not contains(pre_out, "\\icon{star@@") then
  fail("macro annotation did not respect command-name boundaries")
end
if not contains(pre_out, "\\begin{rawtabular}{ll}") then
  fail("tabular with a position argument was not renamed")
end
if not contains(pre_out, pre_src .. ":5: inline \\bigskip") then
  fail("inline skip warning lacks the source file and line:\n" .. pre_out)
end

-- ===== Table splitting ======================================================

local fig = dofile("figure_to_html.lua")
local rows = fig.split_rows([[a & b \\ \begin{pmatrix}1\\2\end{pmatrix} & c \\[2pt] d & $x\\y$ \\]])
if #rows ~= 3 or not contains(rows[2], "\\begin{pmatrix}1\\\\2\\end{pmatrix}")
    or contains(rows[3], "[2pt]") then
  fail("row splitting ignored nesting or row spacing")
end
local cells = fig.split_cells([[\left\{ a & b \} & $c & d$ & \& & {e & f}]])
if #cells ~= 5 then fail("cell splitting miscounted: " .. #cells) end
if table.concat(fig.parse_colspec("l@{\\hspace{1em}}r p{3cm} *{2}{c|}"), "") ~= "lrlcc" then
  fail("column specification parsed incorrectly")
end
local array_html = fig.transform_tex_snippet([[\begin{array}{c} f^*(x) \end{array}]])
if not contains(array_html, "f^*(x)") or contains(array_html, "background-color") then
  fail("*( inside a cell was taken for a colour prefix")
end
local colored = fig.transform_tex_snippet([[\begin{ytableau} *(red) 1 & 2 \end{ytableau}]])
if not contains(colored, "background-color: red") then
  fail("leading *(color) prefix was not applied")
end

-- ===== Bibliography labels and DOI links ===================================

local bib_ok, bib_out = run("REFS_JSON=tests/fixtures/bibliography.json " ..
    "BIBTEX_JSON=tests/fixtures/bibtex-entries.json lua -e " .. shell_quote([[
local bib = dofile("bibhandler.lua")
for _, key in ipairs({ "BrandenA", "BrandenB", "Bjorner", "Many" }) do
  print("base " .. key .. "=" .. tostring(bib.get_bibliography_label(key)))
end
print("alone BrandenA=" .. bib.page_labels({ "BrandenA", "Many" }).BrandenA)
local both = bib.page_labels({ "BrandenB", "BrandenA" })
print("both BrandenA=" .. both.BrandenA .. " BrandenB=" .. both.BrandenB)
print(bib.build_bibliography_HTML(nil, { "BrandenA", "BrandenB", "Many" }))
]]))
if not bib_ok then fail("bibliography fixture failed:\n" .. bib_out) end
for _, expected in ipairs({
  "base BrandenA=Bra04", "base BrandenB=Bra04", "base Bjorner=Bjo05", "base Many=ABCD+99",
  "alone BrandenA=Bra04", "both BrandenA=Bra04a BrandenB=Bra04b",
  "[Bra04a]", "[Bra04b]",
}) do
  if not contains(bib_out, expected) then fail("expected " .. expected .. ":\n" .. bib_out) end
end
for _, doi in ipairs({ "10.1000/alpha", "10.1000/beta", "10.1000/delta" }) do
  if not contains(bib_out, 'href="https://doi.org/' .. doi .. '"') then
    fail("DOI link not normalized for " .. doi)
  end
end
if contains(bib_out, "doi.org/http") or contains(bib_out, "doi.org/doi:") then
  fail("DOI resolver prefix was doubled")
end

-- ===== Render: duplicate ids and source locations ==========================

local labels = write("labels.json", "{}")
local page = write("dup.json", [=[{"pandoc-api-version":[1,23,1],"meta":{},"blocks":[
  {"t":"Div","c":[["same",[],[["data-source-loc","x.tex:1"]]],[]]},
  {"t":"Div","c":[["same",[],[]],[]]}]}]=])
local render_ok, render_out = run("LABELS_JSON=" .. shell_quote(labels) ..
    " lua render.lua " .. shell_quote(page))
if render_ok or not contains(render_out, "id 'same' occurs 2 times") then
  fail("duplicate id was not rejected:\n" .. render_out)
end

-- ===== Merge: relations need a bibliography key ============================

local merge_ok, merge_out, merge_json = gather(polydata("  Contains & safeFamily \\\\"))
if not merge_ok then fail("gather failed for the merge fixture:\n" .. merge_out) end
local outputs = {}
for _, name in ipairs({ "LABELS_JSON", "POLYDATA_JSON", "TODOS_JSON", "SITEMAP_XML",
    "RELATION_GRAPH_HTML", "RELATION_GRAPH_JSON" }) do
  outputs[#outputs + 1] = name .. "=" .. shell_quote(scratch .. "/out-" .. name:lower())
end
local merged_ok, merged_out = run(table.concat(outputs, " ") .. " WWW_DIR=" ..
    shell_quote(scratch) .. " lua merge_meta.lua " .. shell_quote(merge_json))
if merged_ok or not contains(merged_out, "has no bibliography key") then
  fail("relation without a bibliography key was accepted:\n" .. merged_out)
end

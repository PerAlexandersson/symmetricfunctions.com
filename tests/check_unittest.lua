local file_reading = dofile("file_reading.lua")

local function fail(message)
  io.stderr:write("[ERROR] unittest: " .. message .. "\n")
  os.exit(1)
end

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    fail(string.format("%s: expected %q, got %q",
      message, tostring(expected), tostring(actual)))
  end
end

local function contains(haystack, needle)
  return tostring(haystack or ""):find(needle, 1, true) ~= nil
end

local labels_path = os.getenv("LABELS_JSON") or "temp/test-www/meta/site-labels.json"
local polydata_path = os.getenv("POLYDATA_JSON") or "temp/test-www/meta/site-polydata.json"
local html_path = (os.getenv("TEST_HTML") or "temp/test-www/unittest.htm"):match("%S+")
local www_dir = os.getenv("WWW_DIR") or "www"

local labels = file_reading.load_json_file(labels_path, "test labels", true)
local polydata = file_reading.load_json_file(polydata_path, "test polydata", true)
local html = file_reading.read_file(html_path, "test html", true)
local keyword_path = html_path:match("^(.*)/") .. "/site-keywords.json"
local catalogue = file_reading.load_json_file(keyword_path, "test keywords", true)
assert_eq(catalogue.schema_version, 1, "keyword schema version")
local keyword_hrefs = {}
for _, keyword in ipairs(catalogue.keywords) do
  keyword_hrefs[keyword.phrase .. "|" .. keyword.href] = true
end
for _, key in ipairs({
  "definition|unittest.htm",
  "Test tableaux|unittest.htm#testTableaux",
  "Test tableaux|unittest.htm#testTableauxAgain",
  "Möbius functions|unittest.htm",
  "q-test polynomials|unittest.htm",
}) do
  if not keyword_hrefs[key] then fail("missing keyword: " .. key) end
end
for _, keyword in ipairs(catalogue.keywords) do
  if contains(keyword.phrase, "x_1") then fail("formula exported as keyword") end
end

if file_reading.file_exists(www_dir .. "/unittest.htm") then
  fail("unit-test HTML leaked into the deployable www directory")
end

if not labels.testFamily then
  fail("missing testFamily label")
end
assert_eq(labels.testFamily.href, "unittest.htm#testFamily",
  "testFamily label href")

local entry = polydata.testFamily
if type(entry) ~= "table" then
  fail("missing testFamily polydata")
end
assert_eq(entry.Name, "Test polynomials", "testFamily name")

local relation_count = 0
local generalizes_count = 0
local specializes = nil

for _, relation in ipairs(entry.Relations or {}) do
  relation_count = relation_count + 1
  if relation.type == "generalizes" then
    generalizes_count = generalizes_count + 1
  elseif relation.type == "specializes_to" then
    specializes = relation
  end
end

assert_eq(relation_count, 6, "relation count")
assert_eq(generalizes_count, 3, "legacy semicolon relation count")

if not specializes then
  fail("missing SpecializesTo relation")
end
assert_eq(specializes.status, "conjecture", "SpecializesTo status")
assert_eq(specializes.target, "testFamily", "SpecializesTo target")
assert_eq((specializes.refs or {})[1], "Jacobi1841", "SpecializesTo first ref")
assert_eq((specializes.refs or {})[2], "Cauchy1815", "SpecializesTo second ref")
assert_eq((specializes.attrs or {}).map, "q=0", "SpecializesTo map attr")
assert_eq((specializes.attrs or {}).note, "unit test", "SpecializesTo note attr")

if not contains(html, 'href="unittest.htm#testFamily"') then
  fail("rendered unittest HTML did not resolve local hyperref")
end

if not contains(html, 'href="unittest.htm#testFamily" class="hyperref"') or
   not contains(html, '>table link</a>') then
  fail("rendered unittest HTML did not resolve hyperref inside a tabular cell")
end

if contains(html, '&lt;span') or contains(html, '&lt;strong') then
  fail("rendered unittest HTML escaped inline HTML inside a tabular cell")
end

if contains(html, [[\toprule]]) or contains(html, [[\midrule]]) or
   contains(html, [[\bottomrule]]) then
  fail("rendered unittest HTML leaked booktabs commands from an array")
end

if not contains(html, [[\(i\lt{}j\) and \(j\gt{}i.\)]]) then
  fail("raw math angle brackets were not normalized to \\lt{} and \\gt{}")
end

if not contains(html, "a &amp;&lt; b") then
  fail("raw angle bracket in an unlisted display-math environment was not escaped")
end

for _, expected_name in ipairs({
  "Ś. Gal",
  "N. González",
  "É. Tétreault",
  "M.-P. Schützenberger",
  "Š. Gal",
}) do
  if not contains(html, ">" .. expected_name .. "</a>") then
    fail("Unicode name did not render correctly: " .. expected_name)
  end
end

if contains(html, "�") or contains(html, [[Gonz{\'a}lez]])
    or contains(html, [[T{\'e}treault]]) then
  fail("Unicode name rendering leaked replacement characters or raw TeX")
end

if not contains(html, "q=%C5%9Awi%C4%99tos%C5%82aw%20Gal%20mathematics") then
  fail("Scholar query was not percent-encoded")
end

if not contains(html, 'href="https://example.com/~u/a_b%20c#f"') or
   not contains(html, '>example.com/~u/a_b%20c#f</a>') then
  fail("special-character URL did not retain its href and display text")
end

local plain_html = html:gsub("<[^>]->", ""):gsub("\194\160", " ")
if not contains(plain_html, "[Cau15, Sch01, Thm. 3.1]") then
  fail("multi-cite suffix was not rendered after the final citation")
end
if not contains(plain_html, "[see Cau15, p. 4]") then
  fail("citation prefix/suffix was not preserved")
end

if not contains(html, '>A &amp; B</span>') or
   not contains(html, "grid-template-columns: repeat(2, auto)") then
  fail("escaped ampersand split a two-column table")
end

if not contains(html,
    '<li><a href="#testRichToc" class="subsection">The key and A. Lascoux &amp; co polynomials</a></li>') then
  fail("rich TOC entry was incomplete or not escaped")
end

if not contains(html, 'alt="Young&#39;s lattice"') or
   contains(html, 'alt="Young&amp;#39;s lattice"') then
  fail("image alt text was not escaped exactly once")
end

if not contains(html,
    'grid-template-rows: repeat(2, auto); grid-template-columns: repeat(3, auto)">\n' ..
    '<span class="cell-none border-s border-e" style="grid-row: 1; grid-column: 1">&nbsp;</span>\n' ..
    '<span class="border-n border-s border-e" style="grid-row: 1; grid-column: 2">$1$</span>') then
  fail("bare \\none was not tokenized as one tableau cell")
end

if not contains(html, 'class="bibtex-details"') then
  fail("bibliography did not render expandable BibTeX details")
end

if not contains(html, '@article{Cauchy1815,') then
  fail("bibliography did not include raw BibTeX for cited entries")
end

if not contains(html, '<img src="svg-images/transfer-matrix-triomino-transition-ad.svg"') or
   not contains(html, 'alt="A to D: square and triomino"') or
   contains(html, '&lt;img') then
  fail("native table did not preserve its inline SVG image and alternative text")
end

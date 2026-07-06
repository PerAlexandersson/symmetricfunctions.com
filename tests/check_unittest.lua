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

local labels_path = os.getenv("LABELS_JSON") or "temp/test-site-labels.json"
local polydata_path = os.getenv("POLYDATA_JSON") or "temp/test-site-polydata.json"
local html_path = (os.getenv("TEST_HTML") or "www/unittest.htm"):match("%S+")

local labels = file_reading.load_json_file(labels_path, "test labels", true)
local polydata = file_reading.load_json_file(polydata_path, "test polydata", true)
local html = file_reading.read_file(html_path, "test html", true)

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

if not contains(html, [[\(i\lt{}j\) and \(j\gt{}i.\)]]) then
  fail("raw math angle brackets were not normalized to \\lt{} and \\gt{}")
end

if not contains(html, 'class="bibtex-details"') then
  fail("bibliography did not render expandable BibTeX details")
end

if not contains(html, '@article{Cauchy1815,') then
  fail("bibliography did not include raw BibTeX for cited entries")
end

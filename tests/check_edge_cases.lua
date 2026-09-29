local function fail(message)
  io.stderr:write("[ERROR] edge-cases: " .. message .. "\n")
  os.exit(1)
end

local function contains(text, needle)
  return text:find(needle, 1, true) ~= nil
end

local function run(command)
  local pipe, err = io.popen(command .. " 2>&1")
  if not pipe then fail("could not run command: " .. tostring(err)) end
  local output = pipe:read("*a")
  local ok, why, code = pipe:close()
  return ok == true, output, why, code
end

local fixture = "tests/fixtures/preprocess.tex"
local ok, output = run("lua preprocess.lua " .. fixture .. " < " .. fixture)
if not ok then fail("preprocess fixture command failed:\n" .. output) end

local protected_comment =
  [[% Protected comment: \cite{Missing} $x$. {proof} \url{https://x/%20}]]
if not contains(output, protected_comment) then
  fail("comment content was rewritten")
end
if not contains(output,
    [[$p$% This comment must not become part of the punctuation character class.]]) then
  fail("percent comment after math was treated as punctuation")
end

local protected_verbatim = [[\begin{verbatim}
\cite{Missing}
$x$.
{proof}
\url{https://example.com/a%20b}
\end{verbatim}]]
if not contains(output, protected_verbatim) then
  fail("verbatim content was rewritten")
end

if not contains(output, [[\begin{lstlisting}
\hyperref[missing]{proof} $y$.
\end{lstlisting}]]) then
  fail("lstlisting content was rewritten")
end
if not contains(output, [[\verb|\cite{Missing} $z$. {proof}|]]) then
  fail("inline verb content was rewritten")
end

if not output:match("\\hyperref%[testFamily@@tests/fixtures/preprocess%.tex:%d+%]{proof}") then
  fail("real hyperref was not annotated or its display text was rewritten")
end
if not contains(output, "\\begin{symproof}") or
   not contains(output, "\\end{symproof}") then
  fail("proof environment delimiters were not renamed")
end
if contains(output, "{symproof} text") then
  fail("ordinary proof text was renamed")
end
if not contains(output, "$f$: value") or not contains(output, "$f.$") then
  fail("dollar-math punctuation handling is incorrect")
end
if not contains(output, [[\(g\): value]]) or not contains(output, [[\(g.\)]]) then
  fail("parenthesized-math punctuation handling is incorrect")
end
if not contains(output, [[\url{https://example.com/~u/a_b%20c#f}]]) then
  fail("URL command was rewritten")
end
if not output:match(
    "\\cite%[see%]%[p%.~4%]%{Cauchy1815@@tests/fixtures/preprocess%.tex:%d+%}") then
  fail("multi-optional citation was not annotated")
end

local figure_to_html = dofile("figure_to_html.lua")
local table_html, table_err = figure_to_html.transform_tex_snippet(
  [[\begin{rawtabular}{l}A &amp; B <raw>\\\end{rawtabular}]])
if table_err then
  fail("raw-table entity fixture failed: " .. table_err)
end
if not contains(table_html, "A &amp; B &lt;raw&gt;") or
   contains(table_html, "&amp;amp;") or contains(table_html, "<raw>") then
  fail("encoded table entity incorrectly trusted adjacent raw HTML: " .. table_html)
end

local unsupported = "tests/fixtures/unsupported-cite.tex"
local unsupported_ok, unsupported_output = run(
  "lua preprocess.lua " .. unsupported .. " < " .. unsupported ..
  " | pandoc --from=latex+raw_tex --to=json --lua-filter=gather.lua " ..
  "--fail-if-warnings -o /dev/null")
if unsupported_ok then
  fail("unsupported citation mode unexpectedly succeeded")
end
if not contains(unsupported_output, "Unsupported citation mode AuthorInText") or
   not contains(unsupported_output, unsupported .. ":6") then
  fail("unsupported citation mode lacked a source-located diagnostic:\n" ..
       unsupported_output)
end
if not contains(unsupported_output, "Unsupported citation mode SuppressAuthor") or
   not contains(unsupported_output, unsupported .. ":7") then
  fail("suppressed-author citation lacked a source-located diagnostic:\n" ..
       unsupported_output)
end

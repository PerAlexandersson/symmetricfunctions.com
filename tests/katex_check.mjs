// KaTeX syntax checker backend for tests/lint_katex.py.
//
// Mirrors the browser renderer: the pinned KaTeX release, the real
// window.KATEX_MACROS table from tex-init.js, auto-render's own
// splitAtDelimiters, the delimiter list and options of assets/site.js and
// assets/relation-graph.js, and one shared macros object per page (so \gdef
// carries over as it does in the browser).  The only difference is
// throwOnError: true, so every formula that the browser would show as red
// error text is reported.
//
// Usage: node katex_check.mjs KATEX_PACKAGE_DIR TEX_INIT_JS EXPECTED_VERSION
// Input (stdin):  {"pages": [{"page": str, "runs": [{"text": str, "loc": str,
//                  "line": int|null}]}]}
// Output (stdout): JSON report, see the end of this file.

import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';

const [katexDir, texInitPath, expectedVersion] = process.argv.slice(2);
if (!katexDir || !texInitPath || !expectedVersion) {
  console.error('usage: node katex_check.mjs KATEX_PACKAGE_DIR TEX_INIT_JS EXPECTED_VERSION');
  process.exit(2);
}

const require = createRequire(import.meta.url);
const katex = require(path.join(katexDir, 'dist', 'katex.js'));
if (katex.version !== expectedVersion) {
  console.error(`[ERROR] lint-katex: loaded KaTeX ${katex.version} from ${katexDir}, `
    + `but template.htm pins ${expectedVersion}`);
  process.exit(2);
}
const splitAtDelimiters = (await import(pathToFileURL(
  path.join(katexDir, 'contrib', 'auto-render', 'splitAtDelimiters.js')).href)).default;

// Evaluate tex-init.js exactly as the browser does: it assigns
// window.KATEX_MACROS.
const sandbox = { window: {} };
vm.runInNewContext(fs.readFileSync(texInitPath, 'utf8'), sandbox, { filename: texInitPath });
const siteMacros = sandbox.window.KATEX_MACROS;
if (!siteMacros || typeof siteMacros !== 'object') {
  console.error(`[ERROR] lint-katex: ${texInitPath} did not define window.KATEX_MACROS`);
  process.exit(2);
}

// Delimiters and options of initKatex() in assets/site.js and renderNodeMath()
// in assets/relation-graph.js (identical lists).
const DELIMITERS = [
  { left: '$$', right: '$$', display: true },
  { left: '\\[', right: '\\]', display: true },
  { left: '$', right: '$', display: false },
  { left: '\\(', right: '\\)', display: false },
];

// KaTeX's own message underlines the context with combining characters; use
// the raw message and mark the error position with a plain arrow instead.
function describe(e, tex) {
  if (!(e instanceof katex.ParseError)) {
    return `internal error: ${e && e.message ? e.message : String(e)}`;
  }
  let msg = e.rawMessage || e.message;
  if (Number.isInteger(e.position)) {
    const start = Math.max(0, e.position - 25);
    const end = Math.min(tex.length, e.position + Math.max(e.length || 0, 1) + 25);
    const context = (start > 0 ? '…' : '') + tex.slice(start, e.position) + '▸'
      + tex.slice(e.position, end) + (end < tex.length ? '…' : '');
    msg += ` at position ${e.position + 1}: ${context.replace(/\n/g, '\\n')}`;
  }
  return msg;
}

function parseError(tex, displayMode, macros) {
  try {
    katex.renderToString(tex, { displayMode, output: 'html', throwOnError: true, macros });
    return null;
  } catch (e) {
    return describe(e, tex);
  }
}

const REGEX_LEFT = new RegExp('(' + DELIMITERS.map(
  (d) => d.left.replace(/[-/\\^$*+?.()|[\]{}]/g, '\\$&')).join('|') + ')');

function lineOf(text, offset) {
  let n = 0;
  for (let i = 0; i < offset; i++) if (text.charCodeAt(i) === 10) n++;
  return n;
}

// --- 1. Macro table self-test -------------------------------------------
// Every macro is invoked with as many dummy arguments as its body uses,
// inline, displayed and inside a braced script.  A fresh copy of the table is
// used for each case so that one broken macro cannot mask another.
const macroErrors = [];
let macroCases = 0;
for (const [name, body] of Object.entries(siteMacros)) {
  if (!/^\\(?:[A-Za-z]+|.)$/.test(name)) {
    macroErrors.push({ macro: name, invocation: name, message: 'macro name is not a single control sequence' });
    continue;
  }
  if (typeof body !== 'string') {
    macroErrors.push({ macro: name, invocation: name, message: 'macro expansion is not a string' });
    continue;
  }
  let arity = 0;
  for (const m of body.matchAll(/#([1-9])/g)) arity = Math.max(arity, Number(m[1]));
  const args = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'].slice(0, arity).map((x) => `{${x}}`).join('');
  const call = name + args;
  const cases = [
    [call, false],
    [call, true],
    [`x_{${call}}^{${call}}`, false],
    [`${call} + ${call}`, false],
  ];
  for (const [tex, display] of cases) {
    macroCases++;
    const err = parseError(tex, display, Object.assign({}, siteMacros));
    if (err) {
      macroErrors.push({ macro: name, invocation: tex, display, message: err });
      break;
    }
  }
}

// --- 2. Formulas that reach the renderer --------------------------------
const input = JSON.parse(fs.readFileSync(0, 'utf8'));
const formulaErrors = [];
let formulaCount = 0;
let pageCount = 0;
const delimiterCounts = {};

for (const page of input.pages) {
  pageCount++;
  // renderMathInElement passes window.KATEX_MACROS itself, so \gdef persists
  // for the rest of the page.  Copy per page: each page is a fresh window.
  const macros = Object.assign({}, siteMacros);
  for (const run of page.runs) {
    const pieces = splitAtDelimiters(run.text, DELIMITERS);
    let offset = 0;
    for (const piece of pieces) {
      if (piece.type === 'math') {
        formulaCount++;
        const left = DELIMITERS.find((d) => piece.rawData.startsWith(d.left)).left;
        delimiterCounts[left] = (delimiterCounts[left] || 0) + 1;
        const err = parseError(piece.data, piece.display, macros);
        if (err) {
          formulaErrors.push({
            page: page.page,
            loc: run.loc,
            line: run.line == null ? null : run.line + lineOf(run.text, offset),
            delimiter: left,
            display: piece.display,
            formula: piece.rawData,
            message: err,
          });
        }
        offset += piece.rawData.length;
      } else {
        // splitAtDelimiters gives up when it cannot find the closing
        // delimiter at brace depth zero; the browser then shows the raw TeX.
        // A run consisting of a lone "$" is a literal dollar (render.lua
        // wraps TeX \$ in its own element), which auto-render leaves alone.
        const at = piece.data.search(REGEX_LEFT);
        if (at >= 0 && piece === pieces[pieces.length - 1] && run.text.trim() !== '$') {
          const rest = piece.data.slice(at);
          const left = DELIMITERS.find((d) => rest.startsWith(d.left));
          formulaErrors.push({
            page: page.page,
            loc: run.loc,
            line: run.line == null ? null : run.line + lineOf(run.text, offset + at),
            delimiter: left.left,
            display: left.display,
            formula: rest,
            message: `unterminated formula: no closing ${left.right} for this ${left.left} `
              + 'at brace depth zero (unbalanced braces?), so the raw TeX is shown as text',
          });
        }
        offset += piece.data.length;
      }
    }
  }
}

process.stdout.write(JSON.stringify({
  katex_version: katex.version,
  macro_count: Object.keys(siteMacros).length,
  macro_cases: macroCases,
  macro_errors: macroErrors,
  page_count: pageCount,
  formula_count: formulaCount,
  delimiter_counts: delimiterCounts,
  formula_errors: formulaErrors,
}));

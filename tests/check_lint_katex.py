#!/usr/bin/env python3
"""Regressions for tests/lint_katex.py (run by make unittest).

Synthetic pages in a temporary directory show that malformed formulas,
unterminated formulas and broken macro definitions fail with the page, line,
formula and KaTeX message; that the site macros (with their arguments) pass;
that \\gdef is shared within a page but not across pages; that code, pre,
script, comments, the <head>, literal dollars and pages without auto-render
are not checked; that relation-graph node labels are checked; and that a
KaTeX version mismatch is a setup error.  Finally the real pipeline output of
tests/unittest.tex (TEST_HTML) must pass.

Requires KATEX_DIR (see make katex-deps).  Uses only the standard library.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LINT = os.path.join(ROOT, "tests", "lint_katex.py")
TEX_INIT = os.path.join(ROOT, "assets", "tex-init.js")
TEMPLATE = os.path.join(ROOT, "template.htm")
KATEX_DIR = os.environ.get("KATEX_DIR", "")


def page(body: str, head: str = "", katex: str = "0.16.25", auto_render: bool = True,
         extra_scripts: str = "") -> str:
    scripts = f'<script defer src="https://cdn.jsdelivr.net/npm/katex@{katex}/dist/katex.min.js"></script>\n'
    if auto_render:
        scripts += (f'<script defer src="https://cdn.jsdelivr.net/npm/katex@{katex}'
                    '/dist/contrib/auto-render.min.js"></script>\n')
    scripts += '<script src="./tex-init.js" defer></script>\n' + extra_scripts
    return f"<!DOCTYPE html>\n<html>\n<head>\n{head}\n{scripts}</head>\n<body>\n{body}\n</body>\n</html>\n"


GOOD = page(head=r"<title>\(\undefinedInHead\)</title>", body=r"""
<p>Site macros with arguments: \(\qbinom{n}{k}_q\), \(\abs{x-y}\),
\(\fallingFactorial{x}{k}\) and \(\defin{\lambda}\).</p>
<p>\[\schurS_\lambda(\xvec) = \sum_{T \in \SSYT(\lambda)} \xvec^T\]</p>
<div class="ytableau"><span>$\schurS_{\mu}$</span><span>$$\catalan_n$$</span></div>
<p>Entities are decoded first: \(x &lt; y\ \text{and}\ y &gt; z\).</p>
<p>Shared definitions: \(\gdef\myvar{y}\myvar\), later \(\myvar^2\).</p>
<p>It costs <span class="tex-dollar">$</span>5 and <span class="tex-dollar">$</span>10.</p>
<p>Code is skipped: <code>\(\undefinedInCode\)</code>
<code>$\undefinedInCode{$</code></p>
<pre>\[\undefinedInPre{\]</pre>
<script>var s = "\\(\\undefinedInScript\\)";</script>
<textarea>\(\undefinedInTextarea\)</textarea>
<select><option>\(\undefinedInOption\)</option></select>
<noscript>\(\undefinedInNoscript\)</noscript>
<!-- \(\undefinedInComment\) -->
""")

GOOD_FORMULAS = 10

BAD = page(body=r"""
<p>Undefined: \(\notAMacro x\).</p>
<p>Brace: \(\frac{1}{2}}\) and depth
\(\frac{1}{2\) never closes \(y\).</p>
<p>Script: \(x^\abs{y}\).</p>
<p>\[\label{eq:bad} x = 1\]</p>
<p>Unshared: \(\myvar\).</p>
<span>$\notInCell$</span>
""")

RELATIONS = page(body=r"""
<div data-relation-graph data-graph-src="graph.json">
<script id="relationGraphData" type="application/json">
{"nodes": [{"id": "good", "name": "Schur $\\schurS_\\lambda$", "space": "$\\spaceSym$",
            "symbol": "$\\schurS_\\lambda(\\xvec)$"},
           {"id": "bad", "name": "Broken $\\notANodeMacro$ family", "space": "Sym"}],
 "edges": [{"source": "good", "target": "bad", "type": "contains",
            "attrs": {"scope": "$q=0$", "map": "$\\notAnAttrMacro$"}}]}
</script></div>
""", extra_scripts='<script src="./relation-graph.js?v=12"></script>\n')

NO_RENDER = page(auto_render=False, body=r"<p>\(\notRenderedHere\)</p>")


@unittest.skipUnless(KATEX_DIR, "KATEX_DIR is not set")
class LintKatexTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="lint-katex-")
        self.www = os.path.join(self.tmp, "www")
        self.src = os.path.join(self.tmp, "src")
        os.makedirs(self.www)
        os.makedirs(self.src)
        shutil.copy(TEX_INIT, os.path.join(self.www, "tex-init.js"))

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def write(self, name: str, text: str, base: str | None = None) -> str:
        path = os.path.join(base or self.www, name)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        return path

    def lint(self, *pages: str, template: str = TEMPLATE, tex_init: str | None = None):
        cmd = [sys.executable, LINT, "--katex-dir", KATEX_DIR, "--www", self.www,
               "--src", self.src, "--template", template, "--json"]
        if tex_init:
            cmd += ["--tex-init", tex_init]
        env = dict(os.environ, QUIET_BUILD="1", NO_COLOR="1")
        result = subprocess.run(cmd + list(pages), capture_output=True, text=True, env=env, cwd=self.tmp)
        report = json.loads(result.stdout) if result.stdout.strip() else None
        return result, report

    def test_valid_site_macros_and_ignored_contexts_pass(self):
        good = self.write("good.htm", GOOD)
        result, report = self.lint(good)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(report["formula_errors"], [])
        self.assertEqual(report["macro_errors"], [])
        self.assertEqual(report["formula_count"], GOOD_FORMULAS)
        self.assertGreaterEqual(report["macro_count"], 180)
        self.assertNotIn("undefinedIn", result.stderr)

    def test_malformed_formulas_fail_with_location_formula_and_message(self):
        self.write("bad.tex", "Undefined: \\(\\notAMacro x\\).\n", self.src)
        bad = self.write("bad.htm", BAD)
        result, report = self.lint(bad)
        self.assertEqual(result.returncode, 1, result.stderr)
        errors = {e["formula"]: e for e in report["formula_errors"]}
        expected = {
            r"\(\notAMacro x\)": "Undefined control sequence: \\notAMacro",
            r"\(\frac{1}{2}}\)": "Expected 'EOF', got '}'",
            r"\(x^\abs{y}\)": "Got function '\\left' with no arguments as superscript",
            "\\[\\label{eq:bad} x = 1\\]": "Undefined control sequence: \\label",
            r"\(\myvar\)": "Undefined control sequence: \\myvar",
            r"$\notInCell$": "Undefined control sequence: \\notInCell",
        }
        for formula, message in expected.items():
            self.assertIn(formula, errors, result.stderr)
            self.assertIn(message, errors[formula]["message"])
        unterminated = [e for e in report["formula_errors"] if e["message"].startswith("unterminated")]
        self.assertEqual(len(unterminated), 1, report["formula_errors"])
        self.assertTrue(unterminated[0]["formula"].startswith(r"\(\frac{1}{2\)"))
        self.assertEqual(unterminated[0]["line"], 13)
        self.assertEqual(len(report["formula_errors"]), len(expected) + 1)
        # Human-readable diagnostics: page:line, formula, message, source line.
        rel = os.path.relpath(bad, self.tmp)
        self.assertIn(f"{rel}:11: KaTeX cannot parse inline formula \\(\\notAMacro x\\)", result.stderr)
        self.assertIn("Undefined control sequence: \\notAMacro at position 1: ▸\\notAMacro x", result.stderr)
        self.assertIn("source: " + os.path.join(os.path.relpath(self.src, self.tmp), "bad.tex") + ":1",
                      result.stderr)
        self.assertIn("7 formula error(s), 0 macro error(s)", result.stderr)

    def test_relation_graph_labels_are_checked(self):
        rel = self.write("polynomial-relations.htm", RELATIONS)
        result, report = self.lint(rel)
        self.assertEqual(result.returncode, 1, result.stderr)
        locs = sorted(e["loc"] for e in report["formula_errors"])
        self.assertEqual(len(locs), 2, report["formula_errors"])
        self.assertTrue(locs[0].startswith("relation-graph edge good -> bad map "), locs)
        self.assertTrue(locs[1].startswith("relation-graph node bad name "), locs)
        self.assertIn("\\notANodeMacro", result.stderr)
        self.assertIn("\\notAnAttrMacro", result.stderr)
        # good: name, symbol, space; bad: name; attributes: scope, map
        self.assertEqual(report["formula_count"], 3 + 1 + 2)

    def test_relation_graph_falls_back_to_the_json_file(self):
        self.write("graph.json", json.dumps({"nodes": [{"id": "x", "name": "$\\alsoBad$"}]}))
        rel = self.write("polynomial-relations.htm",
                         RELATIONS.replace('<script id="relationGraphData"', '<script id="other"'))
        result, report = self.lint(rel)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("graph.json", report["formula_errors"][0]["loc"])

    def test_pages_without_auto_render_are_skipped(self):
        skip = self.write("goto.htm", NO_RENDER)
        good = self.write("good.htm", GOOD)
        result, report = self.lint(skip, good)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(report["skipped_pages"], [os.path.relpath(skip, self.tmp)])

    def test_broken_macro_definitions_fail(self):
        with open(TEX_INIT, encoding="utf-8") as f:
            text = f.read()
        broken = text.replace("window.KATEX_MACROS = {", "window.KATEX_MACROS = {\n"
                              '  "\\\\brokenBrace": "{\\\\mathrm{x}",\n'
                              '  "\\\\needsTwo": "\\\\frac{#2}",\n'
                              '  "\\\\badBody": "\\\\undefinedInBody{#1}",', 1)
        tex_init = self.write("broken-tex-init.js", broken)
        good = self.write("good.htm", GOOD)
        result, report = self.lint(good, tex_init=tex_init)
        self.assertEqual(result.returncode, 1, result.stderr)
        bad = {m["macro"]: m for m in report["macro_errors"]}
        self.assertEqual(sorted(bad), ["\\badBody", "\\brokenBrace", "\\needsTwo"])
        self.assertEqual(bad["\\needsTwo"]["invocation"], "\\needsTwo{a}{b}")
        self.assertIn("macro \\badBody does not parse when invoked as \\badBody{a}", result.stderr)

    def test_version_mismatch_is_a_setup_error(self):
        good = self.write("good.htm", GOOD.replace("katex@0.16.25", "katex@0.16.9"))
        result, _ = self.lint(good)
        self.assertEqual(result.returncode, 2)
        self.assertIn("template.htm pins 0.16.25", result.stderr)
        template = self.write("template.htm", page("", katex="0.16.9"))
        result, _ = self.lint(self.write("good2.htm", GOOD.replace("katex@0.16.25", "katex@0.16.9")),
                              template=template)
        self.assertEqual(result.returncode, 2)
        self.assertIn("loaded KaTeX 0.16.25", result.stderr)

    def test_pipeline_output_passes(self):
        """tests/unittest.tex through the real pipeline: \\$, \\verb and lstlisting."""
        pages = [p for p in os.environ.get("TEST_HTML", "").split() if os.path.isfile(p)]
        if not pages:
            self.skipTest("TEST_HTML not built")
        result, report = self.lint(*[os.path.abspath(p) for p in pages], tex_init=TEX_INIT)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertGreater(report["formula_count"], 20)
        self.assertNotIn("notAMacro", result.stderr)


if __name__ == "__main__":
    if not KATEX_DIR:
        print("[ERROR] check_lint_katex: KATEX_DIR is not set (run via make unittest)", file=sys.stderr)
        sys.exit(2)
    unittest.main(verbosity=0)

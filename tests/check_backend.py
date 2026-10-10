"""Subprocess regressions; all generated fixtures live in a temporary directory."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BackendChecks(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="symcat-backend-")
        self.addCleanup(self.scratch.cleanup)
        self.path = Path(self.scratch.name)
        self.env = dict(os.environ)
        # Do not inherit build paths or jobserver flags from the calling Make.
        for key in ("MAKEFLAGS", "MFLAGS", "MAKELEVEL", "MAKEOVERRIDES",
                    "TEMP_DIR", "WWW_DIR", "REFS_JSON", "BIBTEX_JSON",
                    "LABELS_JSON", "POLYDATA_JSON", "TODOS_JSON", "SITEMAP_XML",
                    "RELATION_GRAPH_HTML", "RELATION_GRAPH_JSON", "TEMPLATE"):
            self.env.pop(key, None)

    def run_command(self, *args):
        return subprocess.run(args, cwd=ROOT, env=self.env, text=True,
                              capture_output=True, timeout=60)

    def render_fixture(self, document):
        page = self.path / "page.json"
        page.write_text(json.dumps(document))
        labels = self.path / "labels.json"
        labels.write_text("{}")
        self.env["LABELS_JSON"] = str(labels)
        self.env["TEMPLATE"] = str(ROOT / "template.htm")
        return page, labels

    def assert_render_fails(self, page, diagnostic):
        result = self.run_command("lua", "render.lua", str(page))
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn(diagnostic, result.stderr)
        self.assertEqual(result.stdout, "", "failed render emitted HTML")

    def test_required_json(self):
        for malformed in ("{", "null"):
            with self.subTest(page=malformed):
                page, _ = self.render_fixture({"meta": {}, "blocks": []})
                page.write_text(malformed)
                self.assert_render_fails(page, "Could not decode")
        page, labels = self.render_fixture({"meta": {}, "blocks": []})
        labels.write_text("{")
        self.assert_render_fails(page, "site-labels")
        page, _ = self.render_fixture({})
        self.assert_render_fails(page, "Invalid Pandoc document")
        page.unlink()
        self.assert_render_fails(page, "Could not open")

    def test_polynomial_json(self):
        page, _ = self.render_fixture({"meta": {}, "blocks": [{
            "t": "Div", "c": [["", ["specialblock"],
                [["data-type", "polynomialList"]]], []]}]})
        polydata = self.path / "polydata.json"
        polydata.write_text("{")
        self.env["POLYDATA_JSON"] = str(polydata)
        self.assert_render_fails(page, "site-polydata")

    def test_empty_valid_page(self):
        page, _ = self.render_fixture({"meta": {}, "blocks": []})
        result = self.run_command("lua", "render.lua", str(page))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("<title>Untitled", result.stdout)

    def test_svg_failures_and_success(self):
        for mode in ("source-read", "mkdir", "cleanup", "copy", "compile",
                     "missing-pdf", "pdfinfo", "page-count", "conversion",
                     "named-conversion", "move", "find-open", "find-exit"):
            with self.subTest(failure=mode):
                result = self.run_command("lua", "tests/fixtures/svg_runner.lua", mode)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("[ERROR]", result.stdout + result.stderr)
                self.assertNotIn("Done.", result.stdout)
        for mode in ("success", "fallback", "empty"):
            with self.subTest(success=mode):
                result = self.run_command("lua", "tests/fixtures/svg_runner.lua", mode)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_metadata_builds_and_tracks_raw_bibliography(self):
        # Exercise both real grouped rules on a fresh tiny source tree. A cited
        # relation forces merge to read the raw BibTeX, independently of render.
        source = self.path / "src"
        source.mkdir()
        (source / "audit.tex").write_text(r"""\metatitle{Audit}

\metadescription{Synthetic backend fixture.}

\section[auditFamily]{Audit family}
\begin{polydata}{auditFamily}
Name & Audit family \\
Space & Sym \\
Year & 2026 \\
Rating & 1 \\
Generalizes & auditFamily | Audit2026 \\
\end{polydata}
""")
        bibliography = self.path / "fixture.bib"
        bibliography.write_text(
            "@article{Audit2026, author={Example, Alex}, title={Audit fixture}, "
            "year={2026}, journal={Test}}\n")
        for lane in ("site", "test"):
            with self.subTest(lane=lane):
                build = self.path / lane
                www = self.path / (lane + "-www")
                args = ["make", "--no-print-directory", "-j2", "Q=1",
                        f"SRC_DIR={source}", f"TEST_DIR={source}",
                        f"TEMP_DIR={build}", f"WWW_DIR={www}",
                        f"BIBFILE={bibliography}"]
                target = "meta" if lane == "site" else str(
                    build / "test-www/meta/site-labels.json")
                result = self.run_command(*args, target)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                graph = (www if lane == "site" else build / "test-www") / "polynomial-relations.htm"
                self.assertIn("Audit fixture", graph.read_text())
                raw = build / "bibtex-entries.json"
                records = json.loads(raw.read_text())
                self.assertIn("Audit2026", records)
                raw.write_text(raw.read_text().replace("Audit fixture", "Updated audit fixture"))
                # Ensure a strict mtime ordering without relying on clock resolution.
                latest = max(p.stat().st_mtime for base in (build, www)
                             if base.exists() for p in base.rglob("*") if p.is_file())
                os.utime(raw, (latest + 1, latest + 1))
                result = self.run_command(*args, target)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("Updated audit fixture", graph.read_text())


if __name__ == "__main__":
    unittest.main()

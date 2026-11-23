#!/usr/bin/env python3
"""Check that every formula reaching KaTeX on the generated site parses.

The browser renders math with KaTeX auto-render (assets/site.js, and
assets/relation-graph.js for the relation-graph node labels) using
throwOnError: false, so a malformed formula shows up only as red text on the
live page.  This checker reproduces what the browser does and fails instead:

* the KaTeX version pinned in template.htm, loaded from KATEX_DIR (an npm
  tree outside the repository);
* window.KATEX_MACROS from the deployed tex-init.js, with every macro also
  exercised on its own, with dummy arguments;
* the text nodes that renderMathInElement(document.body) visits: <body>
  only, skipping script, noscript, style, textarea, pre, code and option
  (auto-render's ignored tags), so code snippets and escaped examples are
  not formulas;
* auto-render's own splitAtDelimiters with the site's delimiter list
  ($$..$$, \\[..\\], $..$, \\(..\\)) and one shared macros object per page;
* the relation-graph node labels that relation-graph.js builds from the
  embedded graph data and typesets after the page has loaded.

Pages that do not load auto-render (for instance goto.htm) are skipped,
because the browser does not typeset them either.

Usage:
  python3 tests/lint_katex.py --katex-dir DIR [--www www] [--src tex-source]
                              [--template template.htm] [PAGE.htm ...]
Exit status: 0 when every formula and macro parses, 1 on KaTeX errors,
2 on setup errors (missing KaTeX tree, version mismatch, unreadable input).
"""

from __future__ import annotations

import argparse
import html.parser
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BACKEND = os.path.join(HERE, "katex_check.mjs")

# auto-render's default ignoredTags (site.js does not override them).
IGNORED_TAGS = {"script", "noscript", "style", "textarea", "pre", "code", "option"}
# Children of <template> live in a separate document fragment, which the DOM
# walk does not reach.
UNREACHABLE_TAGS = {"template"}

KATEX_ASSET_RE = re.compile(
    r"""cdn\.jsdelivr\.net/npm/katex@([0-9][0-9A-Za-z.\-]*)/dist/(katex\.min\.js|contrib/auto-render\.min\.js|katex\.min\.css)""")

QUIET = os.environ.get("QUIET_BUILD", "") not in ("", "0")
USE_COLOR = sys.stderr.isatty() and not os.environ.get("NO_COLOR")


def color(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if USE_COLOR else text


def error(msg: str) -> None:
    print(color("31", "[ERROR]") + " " + msg, file=sys.stderr)


def info(msg: str) -> None:
    if not QUIET:
        print(color("36", "[INFO]") + " " + msg)


class SetupError(Exception):
    pass


def pinned_version(template: str) -> str:
    try:
        with open(template, encoding="utf-8") as f:
            text = f.read()
    except OSError as e:
        raise SetupError(f"cannot read {template}: {e}")
    found = {(m.group(2), m.group(1)) for m in KATEX_ASSET_RE.finditer(text)}
    versions = {v for _, v in found}
    assets = {a for a, _ in found}
    if "katex.min.js" not in assets or "contrib/auto-render.min.js" not in assets:
        raise SetupError(f"{template} does not load katex.min.js and auto-render.min.js from jsDelivr")
    if len(versions) != 1:
        raise SetupError(f"{template} mixes KaTeX versions: {', '.join(sorted(versions))}")
    return versions.pop()


class TextRunCollector(html.parser.HTMLParser):
    """Collect the text runs renderMathInElement(document.body) would see.

    A run is a maximal sequence of character data between two markup events,
    i.e. one DOM text node (auto-render concatenates adjacent text nodes, and
    the HTML parser never splits one).  Character references are decoded, as
    textContent is.
    """

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.in_body = False
        self.skip_stack: list[str] = []
        self.runs: list[dict] = []
        self.current: list[str] = []
        self.current_line: int | None = None
        self.katex_versions: set[str] = set()
        self.loads_auto_render = False
        self.loads_tex_init = False
        self.loads_relation_graph = False
        self.graph_roots: list[dict] = []
        self.embedded_graph: str | None = None
        self._in_graph_data = False
        self._graph_chunks: list[str] = []

    # -- markup events end the current text node
    def flush(self) -> None:
        if self.current:
            self.runs.append({"text": "".join(self.current), "line": self.current_line})
        self.current = []
        self.current_line = None

    def handle_starttag(self, tag, attrs):
        self.flush()
        attrs = dict(attrs)
        if tag == "body":
            self.in_body = True
        if tag == "script":
            src = attrs.get("src") or ""
            for m in KATEX_ASSET_RE.finditer(src):
                self.katex_versions.add(m.group(1))
                if m.group(2) == "contrib/auto-render.min.js":
                    self.loads_auto_render = True
            base = src.split("?", 1)[0]
            if base.endswith("tex-init.js"):
                self.loads_tex_init = True
            if base.endswith("relation-graph.js"):
                self.loads_relation_graph = True
            if attrs.get("id") == "relationGraphData":
                self._in_graph_data = True
                self._graph_chunks = []
        if "data-relation-graph" in attrs:
            self.graph_roots.append(attrs)
        if tag in IGNORED_TAGS or tag in UNREACHABLE_TAGS:
            self.skip_stack.append(tag)

    def handle_startendtag(self, tag, attrs):
        self.flush()

    def handle_endtag(self, tag):
        self.flush()
        if tag == "script" and self._in_graph_data:
            self._in_graph_data = False
            if self.embedded_graph is None:
                self.embedded_graph = "".join(self._graph_chunks)
        if tag in self.skip_stack:
            while self.skip_stack:
                if self.skip_stack.pop() == tag:
                    break
        if tag == "body":
            self.in_body = False

    def handle_comment(self, data):
        self.flush()

    def handle_decl(self, decl):
        self.flush()

    def handle_pi(self, data):
        self.flush()

    def handle_data(self, data):
        if self._in_graph_data:
            self._graph_chunks.append(data)
        if not self.in_body or self.skip_stack:
            return
        if not self.current:
            self.current_line = self.getpos()[0]
        self.current.append(data)


def relation_graph_runs(collector: TextRunCollector, www: str, page: str) -> list[dict]:
    """Text nodes that drawNodes() in relation-graph.js typesets.

    Each node contributes an SVG <title> "(name || id) (id)", a title div
    "name || id" and a meta div "space || id".  Every node of the graph data
    is checked: the presets only choose which subset is visible.
    """
    if not (collector.loads_relation_graph and collector.graph_roots):
        return []
    graph_text = collector.embedded_graph
    source = f"{page} #relationGraphData"
    if not (graph_text and graph_text.strip()):
        src = collector.graph_roots[0].get("data-graph-src") or "polynomial-relations.json"
        path = os.path.join(www, src)
        source = os.path.relpath(path)
        try:
            with open(path, encoding="utf-8") as f:
                graph_text = f.read()
        except OSError as e:
            raise SetupError(f"{page}: cannot read relation graph data {path}: {e}")
    try:
        graph = json.loads(graph_text)
    except ValueError as e:
        raise SetupError(f"{source}: malformed relation graph JSON: {e}")
    runs = []
    for node in graph.get("nodes") or []:
        node_id = str(node.get("id", ""))
        name = node.get("name") or node_id
        space = node.get("space") or node_id
        where = f"relation-graph node {node_id} ({source})"
        runs.append({"text": f"{name} ({node_id})", "line": None, "loc": where + " tooltip"})
        runs.append({"text": str(name), "line": None, "loc": where + " title"})
        runs.append({"text": str(space), "line": None, "loc": where + " meta"})
    return runs


def source_hint(src_dir: str, page: str, formula: str, message: str) -> str | None:
    """Best-effort tex-source location for a formula.

    Looks for the longest line of the formula verbatim (with and without
    trailing punctuation, which preprocessing may move); failing that, for the
    first use of an undefined control sequence.
    """
    stem = os.path.splitext(os.path.basename(page))[0]
    path = os.path.join(src_dir, stem + ".tex")
    try:
        with open(path, encoding="utf-8") as f:
            lines = f.read().splitlines()
    except OSError:
        return None
    body = formula
    for left, right in (("$$", "$$"), ("\\[", "\\]"), ("\\(", "\\)"), ("$", "$")):
        if body.startswith(left) and body.endswith(right) and len(body) >= len(left) + len(right):
            body = body[len(left):len(body) - len(right)]
            break
    candidates = sorted({line.strip() for line in body.splitlines()}, key=len, reverse=True)
    candidates += [c.rstrip(".,;: ") for c in candidates]
    for needle in candidates:
        if len(needle) < 3:
            continue
        for n, line in enumerate(lines, 1):
            if needle in line:
                return f"{os.path.relpath(path)}:{n}"
    m = re.search(r"Undefined control sequence: (\\[A-Za-z]+|\\.)", message)
    if m:
        token = re.compile(re.escape(m.group(1)) + r"(?![A-Za-z])")
        for n, line in enumerate(lines, 1):
            if token.search(line):
                return f"{os.path.relpath(path)}:{n} (first use of {m.group(1)})"
    return None


def shorten(text: str, limit: int = 240) -> str:
    text = text.replace("\n", "\\n")
    return text if len(text) <= limit else text[:limit - 3] + "..."


def collect_pages(www: str, pages: list[str], version: str) -> tuple[list[dict], list[str]]:
    payload, skipped = [], []
    for path in pages:
        rel = os.path.relpath(path)
        try:
            with open(path, encoding="utf-8") as f:
                text = f.read()
        except OSError as e:
            raise SetupError(f"cannot read {path}: {e}")
        collector = TextRunCollector()
        collector.feed(text)
        collector.close()
        collector.flush()
        if collector.katex_versions - {version}:
            raise SetupError(
                f"{rel} loads KaTeX {', '.join(sorted(collector.katex_versions))}, "
                f"but template.htm pins {version}")
        if not collector.loads_auto_render:
            skipped.append(rel)
            continue
        if not collector.loads_tex_init:
            raise SetupError(f"{rel} loads auto-render but not tex-init.js")
        runs = [dict(r, loc=f"{rel}:{r['line']}") for r in collector.runs]
        runs.extend(relation_graph_runs(collector, www, rel))
        payload.append({"page": rel, "runs": runs})
    return payload, skipped


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--katex-dir", default=os.environ.get("KATEX_DIR"),
                    help="npm prefix (or package dir) holding the pinned katex package")
    ap.add_argument("--www", default=os.environ.get("WWW_DIR", "www"))
    ap.add_argument("--src", default=os.environ.get("SRC_DIR", "tex-source"))
    ap.add_argument("--template", default=os.environ.get("TEMPLATE", "template.htm"))
    ap.add_argument("--tex-init", default=None, help="defaults to WWW/tex-init.js")
    ap.add_argument("--node", default=os.environ.get("NODE", "node"))
    ap.add_argument("--json", action="store_true", help="print the raw report on stdout")
    ap.add_argument("pages", nargs="*", help="pages to check (default: every WWW/**/*.htm)")
    args = ap.parse_args(argv)

    try:
        if not args.katex_dir:
            raise SetupError("no KaTeX tree given (use --katex-dir or KATEX_DIR)")
        katex_pkg = args.katex_dir
        if not os.path.isfile(os.path.join(katex_pkg, "dist", "katex.js")):
            katex_pkg = os.path.join(args.katex_dir, "node_modules", "katex")
        if not os.path.isfile(os.path.join(katex_pkg, "dist", "katex.js")):
            raise SetupError(f"no katex package under {args.katex_dir} (run make katex-deps)")
        version = pinned_version(args.template)
        tex_init = args.tex_init or os.path.join(args.www, "tex-init.js")
        if not os.path.isfile(tex_init):
            raise SetupError(f"missing {tex_init} (run make copy-assets)")

        pages = args.pages
        if not pages:
            pages = []
            for root, dirs, files in os.walk(args.www):
                dirs[:] = sorted(d for d in dirs if not d.startswith("_"))
                pages.extend(os.path.join(root, f) for f in sorted(files) if f.endswith(".htm"))
            if not pages:
                raise SetupError(f"no .htm files under {args.www}")
        payload, skipped = collect_pages(args.www, pages, version)
    except SetupError as e:
        error(f"lint-katex: {e}")
        return 2

    proc = subprocess.run(
        [args.node, BACKEND, katex_pkg, tex_init, version],
        input=json.dumps({"pages": payload}), capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        error(f"lint-katex: KaTeX backend failed with status {proc.returncode}")
        return 2
    report = json.loads(proc.stdout)
    report["skipped_pages"] = skipped
    if args.json:
        print(json.dumps(report, indent=1))

    for m in report["macro_errors"]:
        error(f"lint-katex: {tex_init}: macro {m['macro']} does not parse when invoked as "
              f"{shorten(m['invocation'])}"
              f"{' (display)' if m.get('display') else ''}: {m['message']}")
    for e in report["formula_errors"]:
        hint = source_hint(args.src, e["page"], e["formula"], e["message"])
        where = e["loc"] if e["line"] is None else f"{e['page']}:{e['line']}"
        mode = "display" if e["display"] else "inline"
        if e["message"].startswith("unterminated"):
            msg = (f"lint-katex: {where}: {mode} formula is never typeset "
                   f"{shorten(e['formula'])}\n        {e['message']}")
        else:
            msg = (f"lint-katex: {where}: KaTeX cannot parse {mode} formula "
                   f"{shorten(e['formula'])}\n        {e['message']}")
        if hint:
            msg += f"\n        source: {hint}"
        error(msg)

    counts = ", ".join(f"{k} {v}" for k, v in sorted(report["delimiter_counts"].items()))
    info(f"lint-katex: KaTeX {report['katex_version']}: {report['formula_count']} formulas "
         f"on {report['page_count']} pages ({counts}); {report['macro_count']} macros in "
         f"{report['macro_cases']} test invocations; skipped (no auto-render): "
         f"{', '.join(skipped) or 'none'}")
    nerr = len(report["macro_errors"]) + len(report["formula_errors"])
    if nerr:
        error(f"lint-katex: {len(report['formula_errors'])} formula error(s), "
              f"{len(report['macro_errors'])} macro error(s)")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))


# CONTRIBUTING

Thank you for your interest in contributing to **symmetricfunctions.com**!
The goal of this project is to maintain a clean and accessible catalog of symmetric functions, 
written in **LaTeX** and converted to HTML.

This document explains the minimal rules for contributing.

---

## 📄 1. Where to edit

All mathematical content and metadata live in:

```
tex-source/*.tex
```

Each page is a separate `.tex` file.
**If you want to add or update content, edit these files only.**

---

## 🧩 2. Metadata in LaTeX

Metadata (name, year, tags, etc.) is encoded directly in the `.tex` files using macros, for example:

```tex
\begin{polydata}{booleanProduct}
  Name   & Boolean product polynomials \\
  Space  & Sym \\
  Basis  & False \\
  Rating & 1 \\
  Bib    & BilleraBilleyTewari2018 \\
  Year   & 2018 \\
  Category & Other \\
\end{polydata}
```

Only basic LaTeX knowledge is required. The build system extracts this metadata automatically.

---

## 🔨 3. Build system

To build the site locally:

```bash
make
```

This will run the Lua filters and generate output into:

```
temp/     (intermediate build files)
www/      (final website output)
```

These directories are **not** version-controlled.

---

## 🚫 4. Do not commit generated files

The following should **not** be committed:

* `www/`
* `temp/`
* Any LaTeX auxiliary files (`*.aux`, `*.log`, etc.)

These are ignored by `.gitignore`.

---

## 🧪 5. Tests

Small example inputs and comparisons can be placed in:

```
tests/
```

Tests help verify that filters (e.g., for tableaux, metadata extraction) behave correctly.

---

## 👷 6. Code contributions

If you want to improve or fix the build system (Lua filters, Makefile):

* Lua scripts live in the project root (`*.lua`)
* Please keep code minimal and dependency-free
* Document non-obvious behavior with short comments

---

## 🛠 7. Filing issues

Feel free to open an issue on GitHub for:

* Incorrect content
* Missing families or topics
* Suggestions for improvements

---

## 🙏 8. Style philosophy

* Keep `.tex` files readable and close to mathematical writing.
* Avoid complicated LaTeX packages.

#!/usr/bin/env python3
"""Convert Traditional Chinese to Simplified Chinese in Typst (.typ) sources.

The scanner is deliberately conservative: Chinese characters are ordinary
letters in Typst, so converting them cannot break the grammar *unless* the
characters belong to something literal.  These regions are copied verbatim:

  * fenced raw blocks (``` ... ```) and inline raw text (`...`)
  * labels (<label>) and references (@label)
  * bare URLs
  * strings that look like file paths (arguments of #include/#import/#image,
    #bibliography, #csv, ...), including import package specs
  * strings that are the value of a ``font:`` argument (font family names
    such as "標楷體" usually must stay Traditional)
  * comments, when --keep-comments is given (they are converted by default)

Everything else -- markup text, ordinary code strings, identifiers, and by
default comments -- is passed to a Traditional -> Simplified converter.

Backend (install either one):
    pip install opencc-python-reimplemented   # provides the ``opencc`` module
    pip install zhconv

OpenCC is preferred: it converts characters and phrases and leaves punctuation
alone.  zhconv additionally normalizes some punctuation (e.g. 「」 -> “”), so
prefer OpenCC when both are installed.

Examples:
    python typst_t2s.py document.typ > document.simplified.typ
    python typst_t2s.py --in-place chapters/
    python typst_t2s.py -o build/ chapters/ --keep-comments
    python typst_t2s.py --check --diff main.typ
    python typst_t2s.py --in-place thesis.typ --protect "標楷體" --protect "乾隆"
"""

from __future__ import annotations

import argparse
import difflib
import functools
import os
import re
import shutil
import sys
import tempfile
from dataclasses import dataclass
from typing import Callable, Iterable


# ---------------------------------------------------------------------------
# Conversion backends
# ---------------------------------------------------------------------------


class ConverterUnavailable(RuntimeError):
    """No Traditional -> Simplified conversion backend could be loaded."""


@dataclass(frozen=True)
class Converter:
    name: str
    convert: Callable[[str], str]


def build_converter(backend: str = "auto", config: str = "t2s") -> Converter:
    """Load OpenCC when available, otherwise zhconv."""
    errors: list[str] = []

    if backend in ("auto", "opencc"):
        try:
            import opencc  # type: ignore[import-not-found]
        except ImportError as exc:
            errors.append(f"opencc: {exc}")
        else:
            try:
                engine = opencc.OpenCC(config)
            except Exception as exc:  # invalid config, broken install, ...
                errors.append(f"opencc config {config!r}: {exc}")
            else:
                return _cached_converter(f"OpenCC({config})", engine.convert)
        if backend == "opencc":
            raise ConverterUnavailable(_backend_help(errors))

    if backend in ("auto", "zhconv"):
        try:
            import zhconv  # type: ignore[import-not-found]
        except ImportError as exc:
            errors.append(f"zhconv: {exc}")
        else:
            # zhconv has no t2s/tw2s/hk2s configs; map to its closest targets.
            target = {"t2s": "zh-hans", "tw2s": "zh-cn", "hk2s": "zh-cn"}.get(
                config, "zh-hans"
            )
            return _cached_converter(
                f"zhconv({target})", lambda text: zhconv.convert(text, target)
            )
        if backend == "zhconv":
            raise ConverterUnavailable(_backend_help(errors))

    raise ConverterUnavailable(_backend_help(errors))


def _cached_converter(name: str, func: Callable[[str], str]) -> Converter:
    # Documents tend to repeat boilerplate; caching keeps repeated
    # #set/show strings cheap to convert.
    @functools.lru_cache(maxsize=8192)
    def convert(text: str) -> str:
        return func(text)

    return Converter(name=name, convert=convert)


def _backend_help(errors: Iterable[str]) -> str:
    lines = ["No Traditional -> Simplified converter is available."]
    lines.extend(f"  - {error}" for error in errors)
    lines.append(
        "Install one of:\n"
        "  pip install opencc-python-reimplemented\n"
        "  pip install zhconv"
    )
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Typst-aware scanning
# ---------------------------------------------------------------------------

# Typst labels may contain letters, digits, "_", "-", ":", and ".".
_LABEL_RE = re.compile(r"<[\w:.\-]+>")

# References point at labels: @fig-one.
_REF_RE = re.compile(r"@[\w:.\-]+")

# Bare URLs in markup.  Protected so links are not silently rewritten.
_URL_RE = re.compile(
    r"(?:https?://|ftp://|mailto:)[^\s<>()\[\]{}]+", re.IGNORECASE
)

# A string with one of these suffixes is treated as a file path.
_PATH_EXT_RE = re.compile(
    r"\.(?:typ|png|jpe?g|gif|svg|webp|bmp|tiff?|pdf|mp3|wav|ogg|flac|"
    r"mp4|webm|mov|avi|mkv|csv|tsv|json|ya?ml|toml|cbor|bib|txt|md|"
    r"html?|xml|zip|gz|tar|ttf|otf|woff2?|wasm)$",
    re.IGNORECASE,
)

# Named argument whose values are font family names.
_FONT_ARG_RE = re.compile(r"\bfont\s*:")
_FONT_SCAN_MAX_BYTES = 8192

# Functions whose first argument is a file path or URL.
_PATH_FUNCTIONS = {
    "include",
    "import",
    "image",
    "audio",
    "video",
    "bibliography",
    "read",
    "csv",
    "json",
    "yaml",
    "toml",
    "cbor",
    "plugin",
    "embed",
}
_PATH_KEYWORD_RE = re.compile(r"(?:^|[^\w.\-])(?:include|import)\s*$")
_CALL_RE = re.compile(r"([A-Za-z_][\w.]*)\s*\(\s*$")

# Placeholder brackets use the Unicode private-use area so converters leave
# them untouched and the source cannot accidentally contain them.
_PROTECT_OPEN = "\ue000T2S"
_PROTECT_CLOSE = "\ue001"


def _at_line_start(text: str, index: int) -> bool:
    """True if only indentation (or a BOM) precedes ``index`` on its line."""
    i = index - 1
    while i >= 0 and text[i] in " \t\ufeff":
        i -= 1
    return i < 0 or text[i] == "\n"


def _find_fence_end(text: str, pos: int, fence_len: int) -> int:
    """End index of a fenced raw block; ``pos`` is just past its opening fence."""
    n = len(text)
    line_end = text.find("\n", pos)
    if line_end < 0:
        return n

    i = line_end + 1
    while i < n:
        j = i
        while j < n and text[j] in " \t":
            j += 1
        k = j
        while k < n and text[k] == "`":
            k += 1
        # Typst closes a raw block with a fence of exactly the same length.
        # Text after that fence on the line is ordinary markup again.
        if k - j == fence_len:
            return k

        line_end = text.find("\n", i)
        if line_end < 0:
            return n
        i = line_end + 1

    return n


def _find_inline_raw_end(text: str, pos: int, count: int) -> int:
    """End index of inline raw opened by exactly ``count`` backticks."""
    needle = "`" * count
    n = len(text)
    i = pos
    while True:
        j = text.find(needle, i)
        if j < 0:
            return n
        before_ok = j == 0 or text[j - 1] != "`"
        end = j + count
        after_ok = end >= n or text[end] != "`"
        if before_ok and after_ok:
            return end
        i = j + 1


def _find_block_comment_end(text: str, start: int) -> int:
    """End index of a (possibly nested) ``/* ... */`` comment."""
    n = len(text)
    depth = 0
    i = start
    while i < n - 1:
        if text[i] == "/" and text[i + 1] == "*":
            depth += 1
            i += 2
        elif text[i] == "*" and text[i + 1] == "/":
            depth -= 1
            i += 2
            if depth == 0:
                return i
        else:
            i += 1
    return n


def _find_string_end(text: str, start: int) -> int | None:
    """End index of a quoted string, or None if it is not closed on this line.

    Typst strings may technically span lines, but treating unbalanced prose
    quotes as strings (and swallowing the rest of the file) is much worse than
    missing the rare multi-line string literal.
    """
    n = len(text)
    i = start + 1
    while i < n:
        char = text[i]
        if char == "\\":
            i += 2
            continue
        if char == '"':
            return i + 1
        if char in "\r\n":
            return None
        i += 1
    return None


def _looks_like_path(value: str) -> bool:
    """Heuristic: is this string a path/URL/package spec rather than prose?"""
    if not value:
        return False
    if "://" in value or value.startswith(("mailto:", "tel:")):
        return True
    if value.startswith(("@", "./", "../", "/", "~/", "\\\\")):
        return True
    if value.endswith(("/", "\\")):
        return True
    if _PATH_EXT_RE.search(value.strip()):
        return True
    # A slash inside a whitespace-free string usually denotes a path.  Prose
    # such as "字串裡有 // 符號" contains whitespace and is not protected.
    if ("/" in value or "\\" in value) and not any(ch.isspace() for ch in value):
        return True
    return False


def _in_font_argument(text: str, pos: int) -> bool:
    """Heuristic: is the string at ``pos`` the value of a ``font:`` argument?

    Font family names (e.g. "標楷體", "新細明體") are identifiers, not prose;
    converting them makes Typst silently fall back to another font.  Font
    tuples are often pretty-printed across several lines, so scan upwards
    through continuation lines, stopping at a new statement, comment, or raw
    fence.
    """
    line_end = pos
    first_line = True
    window_start = pos
    searched = 0

    while True:
        line_start = text.rfind("\n", 0, line_end) + 1
        stripped = text[line_start:line_end].lstrip(" \t")
        if not first_line and stripped.startswith(("#", "//", "/*", "*/", "`")):
            break
        window_start = line_start
        searched += line_end - line_start
        if line_start == 0 or searched >= _FONT_SCAN_MAX_BYTES:
            break
        line_end = line_start - 1
        first_line = False

    window = text[window_start:pos]

    match = None
    for candidate in _FONT_ARG_RE.finditer(window):
        match = candidate
    if match is None:
        return False

    # Walk to the string. A "," at depth 0 starts the next argument and a
    # ")" closes the call, so either means this is no longer the font value.
    # Skip string literals: commas/parentheses inside them do not count.
    i = match.end()
    depth = 0
    while i < len(window):
        char = window[i]
        if char == '"':
            end = _find_string_end(window, i)
            if end is None:
                i += 1
            else:
                i = end
            continue
        if char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
            if depth < 0:
                return False
        elif char == "," and depth == 0:
            return False
        i += 1
    return True


def _in_path_argument(text: str, pos: int) -> bool:
    """Heuristic: is the string at ``pos`` a file-path argument of a call?"""
    line_start = text.rfind("\n", 0, pos) + 1
    line = text[line_start:pos]

    if _PATH_KEYWORD_RE.search(line):
        return True

    match = _CALL_RE.search(line)
    if match is None:
        return False
    function_name = match.group(1).rsplit(".", 1)[-1]
    return function_name in _PATH_FUNCTIONS


# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------


def convert_text(
    text: str,
    converter: Converter,
    *,
    keep_comments: bool = False,
    protect: Iterable[str] = (),
) -> tuple[str, int]:
    """Convert one Typst document.

    Returns ``(converted_text, number_of_changed_characters)``.
    """
    text, protected_words = _protect_words(text, protect)

    n = len(text)
    pieces: list[str] = []
    buf_start = 0
    changed = 0
    i = 0

    def flush(end: int) -> None:
        nonlocal buf_start, changed
        if end > buf_start:
            original = text[buf_start:end]
            simplified = converter.convert(original)
            if simplified != original:
                changed += _char_diff_count(original, simplified)
            pieces.append(simplified)
        buf_start = end

    def protect_span(start: int, end: int) -> None:
        nonlocal buf_start
        flush(start)
        pieces.append(text[start:end])
        buf_start = end

    while i < n:
        char = text[i]

        # Raw text -------------------------------------------------------
        if char == "`":
            j = i
            while j < n and text[j] == "`":
                j += 1
            run_length = j - i
            if run_length >= 3 and _at_line_start(text, i):
                end = _find_fence_end(text, j, run_length)
            else:
                end = _find_inline_raw_end(text, j, run_length)
            protect_span(i, end)
            i = end
            continue

        # Comments -------------------------------------------------------
        if char == "/" and i + 1 < n and text[i + 1] in "/*":
            if text[i + 1] == "/":
                end = text.find("\n", i)
                if end < 0:
                    end = n
            else:
                end = _find_block_comment_end(text, i)
            if keep_comments:
                protect_span(i, end)
            # When comments are converted, merely skip over them while
            # scanning so quotes/backticks inside comments are not parsed.
            i = end
            continue

        # Code strings ---------------------------------------------------
        if char == '"':
            end = _find_string_end(text, i)
            if end is None:  # unbalanced quote in prose; treat it as text
                i += 1
                continue
            value = text[i + 1 : end - 1]
            if (
                _looks_like_path(value)
                or _in_font_argument(text, i)
                or _in_path_argument(text, i)
            ):
                protect_span(i, end)
            i = end
            continue

        # Labels and references -----------------------------------------
        if char == "<":
            match = _LABEL_RE.match(text, i)
            if match:
                protect_span(i, match.end())
                i = match.end()
                continue
            i += 1
            continue

        if char == "@":
            match = _REF_RE.match(text, i)
            if match:
                protect_span(i, match.end())
                i = match.end()
                continue
            i += 1
            continue

        # Bare URLs ------------------------------------------------------
        if char in "hfmHFM":
            match = _URL_RE.match(text, i)
            if match:
                protect_span(i, match.end())
                i = match.end()
                continue

        i += 1

    flush(n)
    result = "".join(pieces)
    return _restore_words(result, protected_words), changed


def _char_diff_count(a: str, b: str) -> int:
    count = abs(len(a) - len(b))
    count += sum(1 for x, y in zip(a, b) if x != y)
    return count


def _protect_words(
    text: str, words: Iterable[str]
) -> tuple[str, list[tuple[str, str]]]:
    """Replace user-protected words with opaque placeholders."""
    saved: list[tuple[str, str]] = []
    unique_words = dict.fromkeys(word for word in words if word)
    for index, word in enumerate(unique_words):
        token = f"{_PROTECT_OPEN}{index}{_PROTECT_CLOSE}"
        if token in text:
            raise ValueError("input already contains the internal placeholder")
        if word in text:
            text = text.replace(word, token)
            saved.append((token, word))
    return text, saved


def _restore_words(text: str, saved: list[tuple[str, str]]) -> str:
    for token, word in saved:
        text = text.replace(token, word)
    return text


# ---------------------------------------------------------------------------
# File handling
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class InputFile:
    path: str
    base: str  # directory used to preserve relative paths under -o
    from_directory: bool


def gather_inputs(paths: Iterable[str]) -> list[InputFile]:
    found: list[InputFile] = []
    seen: set[str] = set()

    def add(path: str, base: str, from_directory: bool) -> None:
        key = os.path.realpath(path)
        if key in seen:
            return
        seen.add(key)
        found.append(InputFile(path, base, from_directory))

    for raw in paths:
        path = os.path.abspath(raw)
        if os.path.isdir(path):
            base = path
            for root, dirs, files in os.walk(path):
                dirs[:] = sorted(d for d in dirs if not d.startswith("."))
                for name in sorted(files):
                    if name.lower().endswith(".typ"):
                        add(os.path.join(root, name), base, True)
        elif os.path.isfile(path):
            add(path, os.path.dirname(path), False)
        else:
            raise FileNotFoundError(raw)

    return found


def read_source(path: str) -> str:
    # newline="" preserves CRLF / LF exactly.
    with open(path, "r", encoding="utf-8", newline="") as file:
        return file.read()


def write_source(path: str, text: str) -> None:
    """Write atomically so an interrupted run cannot truncate the source."""
    parent = os.path.dirname(os.path.abspath(path))
    os.makedirs(parent, exist_ok=True)
    fd, temp_path = tempfile.mkstemp(
        dir=parent, prefix=".typst_t2s-", suffix=".tmp"
    )
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as file:
            file.write(text)
        if os.path.exists(path):
            shutil.copymode(path, temp_path)
        else:
            os.chmod(temp_path, 0o644)
        os.replace(temp_path, path)
    except BaseException:
        try:
            os.unlink(temp_path)
        except OSError:
            pass
        raise


def plan_outputs(
    files: list[InputFile], output: str | None, in_place: bool
) -> list[tuple[str, str | None]]:
    """Return (source, destination) pairs; destination None means stdout."""
    if in_place:
        return [(file.path, file.path) for file in files]

    if output is None:
        if len(files) != 1 or files[0].from_directory:
            raise ValueError(
                "writing to stdout requires a single file input; "
                "use --in-place or --output for multiple files/directories"
            )
        return [(files[0].path, None)]

    destination = os.path.abspath(output)
    directory_mode = (
        os.path.isdir(destination)
        or len(files) > 1
        or any(file.from_directory for file in files)
        or destination.endswith(("/", "\\", os.sep))
    )

    if not directory_mode and len(files) == 1:
        return [(files[0].path, destination)]

    targets: list[tuple[str, str | None]] = []
    used: set[str] = set()
    for file in files:
        relative = os.path.relpath(file.path, file.base)
        target = os.path.join(destination, relative)
        key = os.path.normcase(os.path.abspath(target))
        if key in used:
            raise ValueError(f"multiple inputs would be written to {target}")
        used.add(key)
        targets.append((file.path, target))
    return targets


def _display(path: str) -> str:
    try:
        return os.path.relpath(path)
    except ValueError:
        return path


def _write_unified_diff(
    original: str, simplified: str, source: str
) -> None:
    diff = difflib.unified_diff(
        original.splitlines(keepends=True),
        simplified.splitlines(keepends=True),
        fromfile=_display(source),
        tofile=f"{_display(source)} (simplified)",
    )
    for line in diff:
        sys.stdout.write(line)
        # difflib does not terminate a diff line when the source file has no
        # final newline; add one for readability (output only, not the file).
        if not line.endswith(("\n", "\r")):
            sys.stdout.write("\n")


def _configure_stdout() -> None:
    try:
        sys.stdout.reconfigure(encoding="utf-8", newline="")
    except (AttributeError, ValueError):
        pass


# ---------------------------------------------------------------------------
# Command line
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="typst_t2s.py",
        description=(
            "Convert Traditional Chinese to Simplified Chinese in Typst "
            "(.typ) files without breaking Typst syntax."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  %(prog)s document.typ > document.simplified.typ\n"
            "  %(prog)s --in-place chapters/\n"
            "  %(prog)s -o build/ chapters/ --keep-comments\n"
            "  %(prog)s --check --diff main.typ"
        ),
    )
    parser.add_argument(
        "inputs",
        nargs="+",
        metavar="PATH",
        help=".typ file(s) or directories (scanned recursively)",
    )
    parser.add_argument(
        "-o",
        "--output",
        metavar="PATH",
        help="output file (single input) or output directory",
    )
    parser.add_argument(
        "-i",
        "--in-place",
        action="store_true",
        help="rewrite the input files in place",
    )
    parser.add_argument(
        "--keep-comments",
        action="store_true",
        help="leave Typst comments unchanged (default: convert them too)",
    )
    parser.add_argument(
        "--backend",
        choices=("auto", "opencc", "zhconv"),
        default="auto",
        help="conversion backend (default: auto)",
    )
    parser.add_argument(
        "--config",
        default="t2s",
        metavar="NAME",
        help="OpenCC config: t2s (default), tw2s, hk2s; zhconv maps t2s -> zh-hans",
    )
    parser.add_argument(
        "--protect",
        action="append",
        default=[],
        metavar="TEXT",
        help="word/phrase to leave unchanged, e.g. a proper noun or font name "
        "(repeatable)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="write nothing; exit with status 1 if any file would change",
    )
    parser.add_argument(
        "--diff",
        action="store_true",
        help="print a unified diff and write nothing",
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true", help="suppress progress messages"
    )
    parser.add_argument("--version", action="version", version="%(prog)s 1.0")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.in_place and args.output:
        parser.error("--in-place and --output are mutually exclusive")
    if (args.check or args.diff) and (args.in_place or args.output):
        parser.error("--check/--diff cannot be combined with --in-place/--output")

    try:
        converter = build_converter(args.backend, args.config)
    except ConverterUnavailable as exc:
        print(exc, file=sys.stderr)
        return 2

    try:
        files = gather_inputs(args.inputs)
    except FileNotFoundError as exc:
        print(f"error: no such file or directory: {exc}", file=sys.stderr)
        return 2

    if not files:
        if not args.quiet:
            print("No .typ files found.", file=sys.stderr)
        return 0

    if args.check or args.diff:
        # Read-only modes work on any number of files/directories.
        targets = [(file.path, None) for file in files]
        write_to_stdout = args.diff
    else:
        try:
            targets = plan_outputs(files, args.output, args.in_place)
        except ValueError as exc:
            parser.error(str(exc))
        write_to_stdout = any(destination is None for _, destination in targets)

    if write_to_stdout:
        _configure_stdout()

    changed_files = 0
    failures = 0

    for source, destination in targets:
        try:
            original = read_source(source)
        except UnicodeDecodeError as exc:
            print(
                f"{_display(source)}: not valid UTF-8 ({exc}); "
                "Typst sources must be UTF-8",
                file=sys.stderr,
            )
            failures += 1
            continue
        except OSError as exc:
            print(f"{_display(source)}: cannot read: {exc}", file=sys.stderr)
            failures += 1
            continue

        try:
            simplified, changed = convert_text(
                original,
                converter,
                keep_comments=args.keep_comments,
                protect=args.protect,
            )
        except Exception as exc:  # backend errors, placeholder collision, ...
            print(f"{_display(source)}: conversion failed: {exc}", file=sys.stderr)
            failures += 1
            continue

        differs = simplified != original
        if differs:
            changed_files += 1

        if args.diff:
            if differs:
                _write_unified_diff(original, simplified, source)
            continue

        if args.check:
            if not args.quiet:
                status = (
                    f"would change ({changed} character(s))"
                    if differs
                    else "unchanged"
                )
                print(f"{_display(source)}: {status}", file=sys.stderr)
            continue

        if destination is None:
            sys.stdout.write(simplified)
            if not args.quiet:
                status = (
                    f"{changed} character(s) converted"
                    if differs
                    else "unchanged"
                )
                print(f"{_display(source)}: {status}", file=sys.stderr)
            continue

        try:
            if destination == source and not differs:
                if not args.quiet:
                    print(f"{_display(source)}: unchanged", file=sys.stderr)
                continue
            write_source(destination, simplified)
        except OSError as exc:
            print(
                f"{_display(source)}: cannot write {_display(destination)}: {exc}",
                file=sys.stderr,
            )
            failures += 1
            continue

        if not args.quiet:
            source_label = _display(source)
            target_label = _display(destination)
            if source_label == target_label:
                print(
                    f"{source_label}: {changed} character(s) converted",
                    file=sys.stderr,
                )
            else:
                print(
                    f"{source_label} -> {target_label}: "
                    f"{changed} character(s) converted",
                    file=sys.stderr,
                )

    if failures:
        return 2
    if args.check and changed_files:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

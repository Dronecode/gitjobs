#!/usr/bin/env python3
"""Verify and apply Dronecode colour themes for the gitjobs fork.

This fork tracks cncf/gitjobs and we do not want to maintain our own copy of the
UI, so theming is deliberately confined to the `@theme` block in
static/css/styles.src.css. That block defines the primary ramp used by every
`*-primary-*` utility across all 57 templates. Upstream has modified it once in
285 commits, so rewriting it is close to conflict-free, whereas editing
templates is not.

Usage:
    theme.py list                  show available themes
    theme.py verify [name|--all]   check contrast against the required pairs
    theme.py apply <name>          rewrite the @theme block in styles.src.css

Themes live in themes/*.json next to this script.
"""

import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
THEMES_DIR = os.path.join(HERE, "themes")
CSS = os.path.join(
    os.path.dirname(HERE), "gitjobs-server", "static", "css", "styles.src.css"
)

STEPS = ["50", "100", "200", "300", "400", "500", "600", "700", "800", "900", "950"]

# Pairings that exist in the compiled component classes (.btn-primary and
# friends). They cannot be changed without editing templates, so a theme has to
# satisfy them rather than the other way round.
#
# (foreground, background, minimum ratio, what it is)
REQUIRED = [
    ("#ffffff", "600", 4.5, "primary button: white on primary-600"),
    ("#ffffff", "900", 4.5, "primary button hover: white on primary-900"),
    ("900", "50", 4.5, "secondary button: primary-900 on primary-50"),
    ("900", "100", 4.5, "secondary hover: primary-900 on primary-100"),
    ("600", "#ffffff", 4.5, "link: primary-600 on white"),
    # primary-500 is the most used step in the codebase (68 references) and the
    # first version of this list missed it entirely. It is used three ways:
    # text-primary-500 on white (11x), bg-primary-500 with text-white (23x, the
    # pagination hover), and border-primary-500 (33x).
    ("500", "#ffffff", 4.5, "text-primary-500 on white (11 uses)"),
    ("#ffffff", "500", 4.5, "pagination hover: white on primary-500 (23 uses)"),
    # Non-text UI components need 3:1 under WCAG 1.4.11, not 4.5:1.
    ("500", "#ffffff", 3.0, "border-primary-500 on white (33 uses)"),
    ("300", "#ffffff", 3.0, "focus ring: primary-300 on white"),
]


def luminance(hex_color):
    h = hex_color.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    r, g, b = (int(h[i : i + 2], 16) / 255 for i in (0, 2, 4))

    def channel(c):
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)


def contrast(a, b):
    hi, lo = sorted((luminance(a), luminance(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def load(name):
    path = os.path.join(THEMES_DIR, name + ".json")
    if not os.path.isfile(path):
        raise SystemExit("no such theme: {}".format(name))
    return json.load(open(path))


def available():
    return sorted(
        os.path.splitext(os.path.basename(p))[0]
        for p in glob.glob(os.path.join(THEMES_DIR, "*.json"))
    )


def resolve(theme, token):
    """A token is either a literal hex or a step name in this theme."""
    return token if token.startswith("#") else theme["colors"][token]


def verify(theme):
    """Return (failures, checks). Failures are what block `apply`."""
    checks, failures = [], []
    for fg, bg, minimum, label in REQUIRED:
        ratio = contrast(resolve(theme, fg), resolve(theme, bg))
        ok = ratio >= minimum
        checks.append((label, ratio, minimum, ok))
        if not ok:
            failures.append((label, ratio, minimum))

    # A ramp whose steps collapse into each other looks broken in real chrome
    # even when every contrast pair passes, so check monotonic lightness too.
    lums = [luminance(theme["colors"][s]) for s in STEPS]
    for i in range(len(lums) - 1):
        if lums[i] <= lums[i + 1]:
            failures.append(
                (
                    "ramp order: step {} is not lighter than {}".format(
                        STEPS[i], STEPS[i + 1]
                    ),
                    0,
                    0,
                )
            )
    return failures, checks


def render_block(theme):
    lines = ["@theme {"]
    lines.append('  --font-inter: Inter, sans-serif;')
    lines.append('  --font-sans:')
    lines.append('    "Clarity City", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica,')
    lines.append('    Arial, sans-serif, Roboto, Ubuntu, "Apple Color Emoji", "Segoe UI Emoji",')
    lines.append('    "Segoe UI Symbol";')
    lines.append("  /* Dronecode theme: {} */".format(theme["name"]))
    for step in STEPS:
        lines.append("  --color-primary-{}: {};".format(step, theme["colors"][step]))
    lines.append("}")
    return "\n".join(lines)


def apply(theme):
    failures, _ = verify(theme)
    if failures:
        raise SystemExit(
            "refusing to apply {}: {} accessibility failure(s). "
            "Run `theme.py verify {}` to see them.".format(
                theme["name"], len(failures), theme["slug"]
            )
        )
    css = open(CSS).read()
    pattern = re.compile(r"@theme \{.*?\n\}", re.S)
    if not pattern.search(css):
        raise SystemExit("could not find the @theme block in {}".format(CSS))
    open(CSS, "w").write(pattern.sub(render_block(theme), css, count=1))
    print("applied '{}' to {}".format(theme["name"], os.path.relpath(CSS)))
    print("rebuild to see it: cargo build -p gitjobs-server")


def print_verify(theme):
    failures, checks = verify(theme)
    print("{}  ({})".format(theme["name"], theme["slug"]))
    for label, ratio, minimum, ok in checks:
        print(
            "  {:5.2f}:1  need {:.1f}  {}  {}".format(
                ratio, minimum, "PASS" if ok else "FAIL", label
            )
        )
    ramp_issues = [f for f in failures if f[0].startswith("ramp order")]
    for issue, _, _ in ramp_issues:
        print("  {}".format(issue))
    print("  -> {}".format("OK" if not failures else "{} FAILURE(S)".format(len(failures))))
    print()
    return not failures


def main():
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return 0

    cmd = args[0]

    if cmd == "list":
        for slug in available():
            t = load(slug)
            ok = not verify(t)[0]
            print("  {:16} {:24} {}".format(slug, t["name"], "ok" if ok else "FAILS"))
        return 0

    if cmd == "verify":
        targets = available() if (len(args) < 2 or args[1] == "--all") else [args[1]]
        allok = True
        for slug in targets:
            allok &= print_verify(load(slug))
        return 0 if allok else 1

    if cmd == "apply":
        if len(args) < 2:
            raise SystemExit("usage: theme.py apply <name>")
        apply(load(args[1]))
        return 0

    raise SystemExit("unknown command: {}".format(cmd))


if __name__ == "__main__":
    sys.exit(main())
